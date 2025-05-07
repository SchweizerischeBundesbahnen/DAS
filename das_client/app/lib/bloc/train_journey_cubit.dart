import 'dart:async';

import 'package:app/pages/journey/train_journey/automatic_advancement_controller.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/util/error_code.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'train_journey_state.dart';

class TrainJourneyCubit extends Cubit<TrainJourneyState> {
  TrainJourneyCubit({
    required SferaRemoteRepo sferaService,
  })  : _sferaService = sferaService,
        super(SelectingTrainJourneyState(date: DateTime.now(), ru: Ru.sbbP));

  final SferaRemoteRepo _sferaService;

  Stream<Journey?> get journeyStream => _sferaService.journeyStream;

  final _settingsSubject = BehaviorSubject<TrainJourneySettings>.seeded(TrainJourneySettings());

  Stream<TrainJourneySettings> get settingsStream => _settingsSubject.stream;

  TrainJourneySettings get settings => _settingsSubject.value;

  StreamSubscription? _stateSubscription;
  StreamSubscription? _journeySubscription;

  AutomaticAdvancementController automaticAdvancementController = AutomaticAdvancementController();

  void loadTrainJourney() async {
    final currentState = state;
    if (currentState is SelectingTrainJourneyState) {
      _resetSettings();
      final date = currentState.date;
      final ru = currentState.ru;
      final trainNumber = currentState.trainNumber?.trim();
      if (ru == null || trainNumber == null) {
        Fimber.i('company or trainNumber null');
        return;
      }

      final trainIdentification = TrainIdentification(ru: ru, trainNumber: trainNumber, date: date);
      emit(ConnectingState(trainIdentification));
      _stateSubscription?.cancel();
      _stateSubscription = _sferaService.stateStream.listen((state) {
        switch (state) {
          case SferaRemoteRepositoryState.connected:
            automaticAdvancementController = AutomaticAdvancementController();
            _listenToJourneyUpdates();
            WakelockPlus.enable();
            emit(TrainJourneyLoadedState(trainIdentification));
            break;
          case SferaRemoteRepositoryState.connecting:
          case SferaRemoteRepositoryState.handshaking:
          case SferaRemoteRepositoryState.loadingJourney:
          case SferaRemoteRepositoryState.loadingAdditionalData:
            emit(ConnectingState(trainIdentification));
            break;
          case SferaRemoteRepositoryState.disconnected:
          case SferaRemoteRepositoryState.offline:
            WakelockPlus.disable();
            final errorCode = _sferaService.lastError != null ? ErrorCode.fromSfera(_sferaService.lastError!) : null;
            emit(SelectingTrainJourneyState(ru: ru, trainNumber: trainNumber, date: date, errorCode: errorCode));
            _journeySubscription?.cancel();
            break;
        }
      });

      // TODO: Use domain model instead of DTO here
      _sferaService.connect(OtnId(company: ru.companyCode, operationalTrainNumber: trainNumber, startDate: date));
    }
  }

  void _resetSettings() {
    _settingsSubject.add(TrainJourneySettings());
  }

  void updateTrainNumber(String? trainNumber) {
    if (state is SelectingTrainJourneyState) {
      emit(SelectingTrainJourneyState(
          trainNumber: trainNumber,
          ru: (state as SelectingTrainJourneyState).ru,
          date: (state as SelectingTrainJourneyState).date,
          errorCode: (state as SelectingTrainJourneyState).errorCode));
    }
  }

  void updateCompany(Ru? ru) {
    if (state is SelectingTrainJourneyState) {
      emit(SelectingTrainJourneyState(
          trainNumber: (state as SelectingTrainJourneyState).trainNumber,
          ru: ru,
          date: (state as SelectingTrainJourneyState).date,
          errorCode: (state as SelectingTrainJourneyState).errorCode));
    }
  }

  void updateDate(DateTime date) {
    if (state is SelectingTrainJourneyState) {
      emit(SelectingTrainJourneyState(
          trainNumber: (state as SelectingTrainJourneyState).trainNumber,
          ru: (state as SelectingTrainJourneyState).ru,
          date: date,
          errorCode: (state as SelectingTrainJourneyState).errorCode));
    }
  }

  void reset() {
    if (state is BaseTrainJourneyState) {
      Fimber.i('Resetting TrainJourney cubit in state $state');
      _sferaService.disconnect();
      final trainIdentification = (state as BaseTrainJourneyState).trainIdentification;
      emit(SelectingTrainJourneyState(
        trainNumber: trainIdentification.trainNumber,
        date: DateTime.now(),
        ru: trainIdentification.ru,
      ));
    }
  }

  @override
  Future<void> close() {
    _journeySubscription?.cancel();
    _journeySubscription = null;
    _stateSubscription?.cancel();
    _stateSubscription = null;

    automaticAdvancementController.dispose();

    return super.close();
  }

  void updateBreakSeries(BreakSeries selectedBreakSeries) {
    _settingsSubject.add(_settingsSubject.value.copyWith(selectedBreakSeries: selectedBreakSeries));

    if (_settingsSubject.value.isAutoAdvancementEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        automaticAdvancementController.scrollToCurrentPosition(resetAutomaticAdvancementTimer: true);
      });
    }
  }

  void updateExpandedGroups(List<int> expandedGroups) {
    _settingsSubject.add(_settingsSubject.value.copyWith(expandedGroups: expandedGroups));
  }

  void updateCollapsedFootnotes(List<String> collapsedGroups) {
    _settingsSubject.add(_settingsSubject.value.copyWith(collapsedFootNotes: collapsedGroups));
  }

  void setAutomaticAdvancement(bool active) {
    Fimber.i('Automatic advancement state changed to active=$active');
    if (active) {
      automaticAdvancementController.scrollToCurrentPosition(resetAutomaticAdvancementTimer: true);
    }
    _settingsSubject.add(_settingsSubject.value.copyWith(isAutoAdvancementEnabled: active));
  }

  void setManeuverMode(bool active) {
    Fimber.i('Maneuver mode state changed to active=$active');
    _settingsSubject.add(_settingsSubject.value.copyWith(isManeuverModeEnabled: active));
  }

  void _listenToJourneyUpdates() {
    _journeySubscription?.cancel();
    _journeySubscription = _sferaService.journeyStream.listen((journey) {
      if (journey != null) {
        _collapsePassedFootNotes(journey);
      }
    });
  }

  void _collapsePassedFootNotes(Journey journey) {
    if (journey.metadata.currentPosition == journey.metadata.lastPosition ||
        journey.metadata.lastPosition == null ||
        journey.metadata.currentPosition == null) {
      return;
    }

    final fromIndex = journey.data.indexOf(journey.metadata.lastPosition!);
    final toIndex = journey.data.indexOf(journey.metadata.currentPosition!);

    final passedFootNotes = journey.data.sublist(fromIndex, toIndex).whereType<BaseFootNote>();

    final newList = List.of(settings.collapsedFootNotes);

    for (final footNote in passedFootNotes) {
      if (settings.collapsedFootNotes.contains(footNote.identifier)) continue;

      if (journey.data.lastIndexWhere((it) => it is BaseFootNote && it.identifier == footNote.identifier) <= toIndex) {
        newList.add(footNote.identifier);
      }
    }

    if (newList.length != settings.collapsedFootNotes.length) {
      updateCollapsedFootnotes(newList);
    }
  }
}

extension ContextBlocExtension on BuildContext {
  TrainJourneyCubit get trainJourneyCubit => read<TrainJourneyCubit>();
}

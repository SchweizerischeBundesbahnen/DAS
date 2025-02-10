import 'dart:async';

import 'package:das_client/app/model/ru.dart';
import 'package:das_client/app/pages/journey/train_journey/automatic_advancement_controller.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:das_client/model/journey/break_series.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:das_client/util/error_code.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

part 'train_journey_state.dart';

class TrainJourneyCubit extends Cubit<TrainJourneyState> {
  TrainJourneyCubit({
    required SferaService sferaService,
  })  : _sferaService = sferaService,
        super(SelectingTrainJourneyState(date: DateTime.now(), ru: Ru.sbbP));

  final SferaService _sferaService;

  Stream<Journey?> get journeyStream => _sferaService.journeyStream;

  final _settingsSubject = BehaviorSubject<TrainJourneySettings>.seeded(TrainJourneySettings());

  Stream<TrainJourneySettings> get settingsStream => _settingsSubject.stream;

  StreamSubscription? _stateSubscription;

  AutomaticAdvancementController automaticAdvancementController = AutomaticAdvancementController();

  void loadTrainJourney() async {
    final currentState = state;
    if (currentState is SelectingTrainJourneyState) {
      _resetSettings();
      final date = currentState.date;
      final ru = currentState.ru;
      final trainNumber = currentState.trainNumber;
      if (ru == null || trainNumber == null) {
        Fimber.i('company or trainNumber null');
        return;
      }

      emit(ConnectingState(ru, trainNumber, currentState.date));
      _stateSubscription?.cancel();
      _stateSubscription = _sferaService.stateStream.listen((state) {
        switch (state) {
          case SferaServiceState.connected:
            automaticAdvancementController = AutomaticAdvancementController();
            emit(TrainJourneyLoadedState(ru, trainNumber, date));
            break;
          case SferaServiceState.connecting:
          case SferaServiceState.handshaking:
          case SferaServiceState.loadingJourney:
          case SferaServiceState.loadingAdditionalData:
            emit(ConnectingState(ru, trainNumber, date));
            break;
          case SferaServiceState.disconnected:
          case SferaServiceState.offline:
            emit(SelectingTrainJourneyState(
                ru: ru, trainNumber: trainNumber, date: date, errorCode: _sferaService.lastErrorCode));
            break;
        }
      });
      _sferaService.connect(OtnId.create(ru.companyCode, trainNumber, date));
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
      emit(SelectingTrainJourneyState(
          trainNumber: (state as BaseTrainJourneyState).trainNumber,
          date: DateTime.now(),
          ru: (state as BaseTrainJourneyState).ru));
    }
  }

  void dispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
  }

  void updateBreakSeries(BreakSeries selectedBreakSeries) {
    _settingsSubject.add(_settingsSubject.value.copyWith(selectedBreakSeries: selectedBreakSeries));
  }

  void updateExpandedGroups(List<int> expandedGroups) {
    _settingsSubject.add(_settingsSubject.value.copyWith(expandedGroups: expandedGroups));
  }

  void setAutomaticAdvancement(bool active) {
    Fimber.i('Automatic advancement state changed to active=$active');
    if (active) {
      automaticAdvancementController.scrollToCurrentPosition();
    }
    _settingsSubject.add(_settingsSubject.value.copyWith(automaticAdvancementActive: active));
  }
}

extension ContextBlocExtension on BuildContext {
  TrainJourneyCubit get trainJourneyCubit => read<TrainJourneyCubit>();
}

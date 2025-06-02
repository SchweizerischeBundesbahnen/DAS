import 'dart:async';

import 'package:app/pages/journey/train_journey/automatic_advancement_controller.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/util/error_code.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:warnapp/component.dart';

class TrainJourneyViewModel {
  TrainJourneyViewModel({
    required SferaRemoteRepo sferaRemoteRepo,
    required WarnappService warnappService,
  }) : _sferaRemoteRepo = sferaRemoteRepo,
       _warnappService = warnappService {
    _init();
  }

  final SferaRemoteRepo _sferaRemoteRepo;
  final WarnappService _warnappService;

  Stream<Journey?> get journey => _sferaRemoteRepo.journeyStream;

  Stream<TrainJourneySettings> get settings => _rxSettings.stream;

  TrainJourneySettings get settingsValue => _rxSettings.value;

  Stream<ErrorCode?> get errorCode => _rxErrorCode.stream;

  Stream<DateTime> get selectedDate => _rxDate.stream;

  Stream<String?> get selectedTrainNumber => _rxTrainNumber.stream;

  Stream<bool> get formCompleted => _rxFormCompleted.stream;

  Stream<RailwayUndertaking> get selectedRailwayUndertaking => _rxRailwayUndertaking.stream;

  Stream<TrainIdentification?> get trainIdentification => _rxTrainIdentification.stream;

  TrainIdentification? get trainIdentificationValue => _rxTrainIdentification.value;

  AutomaticAdvancementController automaticAdvancementController = AutomaticAdvancementController();

  final _rxSettings = BehaviorSubject<TrainJourneySettings>.seeded(TrainJourneySettings());
  final _rxDate = BehaviorSubject<DateTime>.seeded(DateTime.now());
  final _rxTrainNumber = BehaviorSubject<String?>.seeded(null);
  final _rxRailwayUndertaking = BehaviorSubject<RailwayUndertaking>.seeded(RailwayUndertaking.sbbP);
  final _rxErrorCode = BehaviorSubject<ErrorCode?>.seeded(null);
  final _rxTrainIdentification = BehaviorSubject<TrainIdentification?>.seeded(null);
  final _rxFormCompleted = BehaviorSubject<bool>.seeded(false);
  final _subscriptions = <StreamSubscription>[];

  StreamSubscription? _stateSubscription;
  StreamSubscription? _journeySubscription;

  void _init() {
    _initFormComplete();
  }

  void loadTrainJourney() async {
    _resetSettings();
    _rxErrorCode.add(null);

    final date = _rxDate.value;
    final ru = _rxRailwayUndertaking.value;
    final trainNumber = _rxTrainNumber.value;
    if (trainNumber == null) {
      Fimber.i('company or trainNumber null');
      return;
    }

    final trainIdentification = TrainIdentification(ru: ru, trainNumber: trainNumber.trim(), date: date);
    _rxTrainIdentification.add(trainIdentification);

    _stateSubscription?.cancel();
    _stateSubscription = _sferaRemoteRepo.stateStream.listen((state) {
      switch (state) {
        case SferaRemoteRepositoryState.connected:
          automaticAdvancementController = AutomaticAdvancementController();
          _listenToJourneyUpdates();
          WakelockPlus.enable();
          _warnappService.enable();
          break;
        case SferaRemoteRepositoryState.connecting:
        case SferaRemoteRepositoryState.handshaking:
        case SferaRemoteRepositoryState.loadingJourney:
        case SferaRemoteRepositoryState.loadingAdditionalData:
          break;
        case SferaRemoteRepositoryState.disconnected:
        case SferaRemoteRepositoryState.offline:
          WakelockPlus.disable();
          _warnappService.disable();
          if (_sferaRemoteRepo.lastError != null) {
            _rxErrorCode.add(ErrorCode.fromSfera(_sferaRemoteRepo.lastError!));
          }

          _journeySubscription?.cancel();
          break;
      }
    });

    _sferaRemoteRepo.connect(OtnId(company: ru.companyCode, operationalTrainNumber: trainNumber, startDate: date));
  }

  void updateTrainNumber(String? trainNumber) => _rxTrainNumber.add(trainNumber);

  void updateRailwayUndertaking(RailwayUndertaking railwayUndertaking) => _rxRailwayUndertaking.add(railwayUndertaking);

  void updateDate(DateTime date) => _rxDate.add(date);

  void reset() {
    _sferaRemoteRepo.disconnect();
    _rxDate.add(DateTime.now());
    _rxTrainNumber.add(null);
    _rxTrainIdentification.add(null);
  }

  void updateBreakSeries(BreakSeries selectedBreakSeries) {
    _rxSettings.add(_rxSettings.value.copyWith(selectedBreakSeries: selectedBreakSeries));

    if (_rxSettings.value.isAutoAdvancementEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        automaticAdvancementController.scrollToCurrentPosition(resetAutomaticAdvancementTimer: true);
      });
    }
  }

  void updateExpandedGroups(List<int> expandedGroups) {
    _rxSettings.add(_rxSettings.value.copyWith(expandedGroups: expandedGroups));
  }

  void updateCollapsedFootnotes(List<String> collapsedGroups) {
    _rxSettings.add(_rxSettings.value.copyWith(collapsedFootNotes: collapsedGroups));
  }

  void setAutomaticAdvancement(bool active) {
    Fimber.i('Automatic advancement state changed to active=$active');
    if (active) {
      automaticAdvancementController.scrollToCurrentPosition(resetAutomaticAdvancementTimer: true);
    }
    _rxSettings.add(_rxSettings.value.copyWith(isAutoAdvancementEnabled: active));
  }

  void setManeuverMode(bool active) {
    Fimber.i('Maneuver mode state changed to active=$active');
    _rxSettings.add(_rxSettings.value.copyWith(isManeuverModeEnabled: active));
  }

  void dispose() {
    _rxSettings.close();
    _rxDate.close();
    _rxRailwayUndertaking.close();
    _rxTrainNumber.close();
    _rxTrainIdentification.close();

    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _journeySubscription?.cancel();
    _stateSubscription?.cancel();

    automaticAdvancementController.dispose();
  }

  void _resetSettings() => _rxSettings.add(TrainJourneySettings());

  void _listenToJourneyUpdates() {
    _journeySubscription?.cancel();
    _journeySubscription = _sferaRemoteRepo.journeyStream.listen((journey) {
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

    final collapsedFootNotes = _rxSettings.value.collapsedFootNotes;
    final newList = List.of(collapsedFootNotes);

    for (final footNote in passedFootNotes) {
      if (collapsedFootNotes.contains(footNote.identifier)) continue;

      if (journey.data.lastIndexWhere((it) => it is BaseFootNote && it.identifier == footNote.identifier) <= toIndex) {
        newList.add(footNote.identifier);
      }
    }

    if (newList.length != collapsedFootNotes.length) {
      updateCollapsedFootnotes(newList);
    }
  }

  void _initFormComplete() {
    final subscription = _rxTrainNumber.stream
        .map((trainNumber) => trainNumber != null && trainNumber.isNotEmpty)
        .listen(_rxFormCompleted.add, onError: _rxFormCompleted.addError);
    _subscriptions.add(subscription);
  }
}

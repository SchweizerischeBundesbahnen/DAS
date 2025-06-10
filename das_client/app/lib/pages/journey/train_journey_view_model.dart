import 'dart:async';

import 'package:app/pages/journey/train_journey/automatic_advancement_controller.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/util/error_code.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TrainJourneyViewModel {
  TrainJourneyViewModel({
    required SferaRemoteRepo sferaRemoteRepo,
  }) : _sferaRemoteRepo = sferaRemoteRepo {
    _init();
  }

  final SferaRemoteRepo _sferaRemoteRepo;

  Stream<Journey?> get journey => _sferaRemoteRepo.journeyStream;

  Stream<TrainJourneySettings> get settings => _rxSettings.stream;

  TrainJourneySettings get settingsValue => _rxSettings.value;

  Stream<ErrorCode?> get errorCode => _rxErrorCode.stream;

  AutomaticAdvancementController automaticAdvancementController = AutomaticAdvancementController();

  final _rxSettings = BehaviorSubject<TrainJourneySettings>.seeded(TrainJourneySettings());
  final _rxErrorCode = BehaviorSubject<ErrorCode?>.seeded(null);
  final _subscriptions = <StreamSubscription>[];

  StreamSubscription? _stateSubscription;
  StreamSubscription? _journeySubscription;

  void _init() {
    _listenToSferaRemoteRepo();
  }

  void _listenToSferaRemoteRepo() {
    _stateSubscription?.cancel();
    _stateSubscription = _sferaRemoteRepo.stateStream.listen((state) {
      switch (state) {
        case SferaRemoteRepositoryState.connected:
          automaticAdvancementController = AutomaticAdvancementController();
          _listenToJourneyUpdates();
          WakelockPlus.enable();
          break;
        case SferaRemoteRepositoryState.connecting:
        case SferaRemoteRepositoryState.handshaking:
        case SferaRemoteRepositoryState.loadingJourney:
        case SferaRemoteRepositoryState.loadingAdditionalData:
          break;
        case SferaRemoteRepositoryState.disconnected:
        case SferaRemoteRepositoryState.offline:
          WakelockPlus.disable();
          if (_sferaRemoteRepo.lastError != null) {
            _rxErrorCode.add(ErrorCode.fromSfera(_sferaRemoteRepo.lastError!));
          }
          _journeySubscription?.cancel();
          break;
      }
    });
  }

  void reset() {
    _sferaRemoteRepo.disconnect();
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

    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _journeySubscription?.cancel();
    _stateSubscription?.cancel();

    automaticAdvancementController.dispose();
  }

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
}

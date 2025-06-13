import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/train_journey/automatic_advancement_controller.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/time_controller/time_controller.dart';
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
    required WarnappRepository warnappRepo,
  }) : _sferaRemoteRepo = sferaRemoteRepo,
       _warnappRepo = warnappRepo {
    _init();
  }

  static const _warnappWindowMilliseconds = 1250;

  final SferaRemoteRepo _sferaRemoteRepo;
  final WarnappRepository _warnappRepo;

  Stream<Journey?> get journey => _sferaRemoteRepo.journeyStream;

  Stream<TrainJourneySettings> get settings => _rxSettings.stream;

  TrainJourneySettings get settingsValue => _rxSettings.value;

  Stream<ErrorCode?> get errorCode => _rxErrorCode.stream;

  Stream<WarnappEvent> get warnappEvents => _rxWarnapp.stream;

  AutomaticAdvancementController automaticAdvancementController = AutomaticAdvancementController(
    timeController: DI.get<TimeController>(),
  );

  final _rxSettings = BehaviorSubject<TrainJourneySettings>.seeded(TrainJourneySettings());
  final _rxErrorCode = BehaviorSubject<ErrorCode?>.seeded(null);
  final _rxWarnapp = PublishSubject<WarnappEvent>();
  final _subscriptions = <StreamSubscription>[];

  DateTime? _lastWarnappEventTimestamp;

  StreamSubscription? _stateSubscription;
  StreamSubscription? _journeySubscription;
  StreamSubscription? _warnappSignalSubscription;
  StreamSubscription? _warnappAbfahrtSubscription;

  void _init() {
    _listenToSferaRemoteRepo();
  }

  void _listenToSferaRemoteRepo() {
    _stateSubscription?.cancel();
    _stateSubscription = _sferaRemoteRepo.stateStream.listen((state) {
      switch (state) {
        case SferaRemoteRepositoryState.connected:
          final timeController = DI.get<TimeController>();
          automaticAdvancementController = AutomaticAdvancementController(timeController: timeController);
          _listenToJourneyUpdates();
          WakelockPlus.enable();
          _enableWarnapp();
          break;
        case SferaRemoteRepositoryState.connecting:
        case SferaRemoteRepositoryState.handshaking:
        case SferaRemoteRepositoryState.loadingJourney:
        case SferaRemoteRepositoryState.loadingAdditionalData:
          break;
        case SferaRemoteRepositoryState.disconnected:
        case SferaRemoteRepositoryState.offline:
          WakelockPlus.disable();
          _disableWarnapp();
          if (_sferaRemoteRepo.lastError != null) {
            _rxErrorCode.add(ErrorCode.fromSfera(_sferaRemoteRepo.lastError!));
          }
          _journeySubscription?.cancel();
          break;
      }
    });
  }

  void _enableWarnapp() {
    _warnappAbfahrtSubscription = _warnappRepo.abfahrtEventStream.listen((event) => _handleAbfahrtEvent());
    _warnappSignalSubscription = _sferaRemoteRepo.warnappEventStream.listen((event) {
      _lastWarnappEventTimestamp = DateTime.now();
    });
    _warnappRepo.enable();
  }

  void _disableWarnapp() {
    _warnappRepo.disable();
    _warnappAbfahrtSubscription?.cancel();
    _warnappAbfahrtSubscription = null;
    _warnappSignalSubscription?.cancel();
    _warnappSignalSubscription = null;
    _lastWarnappEventTimestamp = null;
  }

  void reset() {
    _sferaRemoteRepo.disconnect();
    _resetSettings();
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

    if (active) {
      _warnappRepo.disable();
    } else {
      _warnappRepo.enable();
    }
  }

  void dispose() {
    _rxSettings.close();
    _rxWarnapp.close();

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

  void _handleAbfahrtEvent() {
    final now = DateTime.now();
    if (_lastWarnappEventTimestamp != null &&
        now.difference(_lastWarnappEventTimestamp!).inMilliseconds < _warnappWindowMilliseconds) {
      Fimber.i('Abfahrt detected while warnapp message was within $_warnappWindowMilliseconds ms -> Warning!');
      _rxWarnapp.add(WarnappEvent());
    }
  }
}

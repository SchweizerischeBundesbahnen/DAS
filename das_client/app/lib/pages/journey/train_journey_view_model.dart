import 'dart:async';

import 'package:app/pages/journey/train_journey/automatic_advancement_controller.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/util/error_code.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:warnapp/component.dart';

final _log = Logger('TrainJourneyViewModel');

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

  AutomaticAdvancementController automaticAdvancementController = AutomaticAdvancementController();

  final _rxSettings = BehaviorSubject<TrainJourneySettings>.seeded(TrainJourneySettings());
  final _rxErrorCode = BehaviorSubject<ErrorCode?>.seeded(null);
  final _rxWarnapp = PublishSubject<WarnappEvent>();

  DateTime? _lastWarnappEventTimestamp;

  StreamSubscription? _stateSubscription;
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
          automaticAdvancementController = AutomaticAdvancementController();
          WakelockPlus.enable();
          _enableWarnapp();
          break;
        case SferaRemoteRepositoryState.connecting:
          break;
        case SferaRemoteRepositoryState.disconnected:
          WakelockPlus.disable();
          _disableWarnapp();
          if (_sferaRemoteRepo.lastError != null) {
            _rxErrorCode.add(ErrorCode.fromSfera(_sferaRemoteRepo.lastError!));
            setAutomaticAdvancement(false);
          }
          break;
      }
    });
  }

  void _enableWarnapp() {
    _warnappAbfahrtSubscription = _warnappRepo.abfahrtEventStream.listen((_) => _handleAbfahrtEvent());
    _warnappSignalSubscription = _sferaRemoteRepo.warnappEventStream.listen((_) {
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

  void setAutomaticAdvancement(bool active) {
    _log.info('Automatic advancement state changed to active=$active');
    if (active) {
      automaticAdvancementController.scrollToCurrentPosition(resetAutomaticAdvancementTimer: true);
    }
    _rxSettings.add(_rxSettings.value.copyWith(isAutoAdvancementEnabled: active));
  }

  void setManeuverMode(bool active) {
    _log.info('Maneuver mode state changed to active=$active');
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
    _stateSubscription?.cancel();
    automaticAdvancementController.dispose();
  }

  void _resetSettings() => _rxSettings.add(TrainJourneySettings());

  void _handleAbfahrtEvent() {
    final now = DateTime.now();
    if (_lastWarnappEventTimestamp != null &&
        now.difference(_lastWarnappEventTimestamp!).inMilliseconds < _warnappWindowMilliseconds) {
      _log.info('Abfahrt detected while warnapp message was within $_warnappWindowMilliseconds ms -> Warning!');
      _rxWarnapp.add(WarnappEvent());
    }
  }
}

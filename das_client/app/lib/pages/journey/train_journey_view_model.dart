import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/train_journey/automatic_advancement_controller.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/util/error_code.dart';
import 'package:app/util/time_constants.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final _log = Logger('TrainJourneyViewModel');

class TrainJourneyViewModel {
  TrainJourneyViewModel({
    required SferaRemoteRepo sferaRemoteRepo,
  }) : _sferaRemoteRepo = sferaRemoteRepo {
    _init();
  }

  final _resetToKmAfterSeconds = DI.get<TimeConstants>().kmDecisiveGradientResetSeconds;

  final SferaRemoteRepo _sferaRemoteRepo;

  final List<void Function(Journey?)> _syncOnJourneyUpdateCallbacks = [];

  Stream<Journey?> get journey => _sferaRemoteRepo.journeyStream;

  Stream<TrainJourneySettings> get settings => _rxSettings.stream;

  TrainJourneySettings get settingsValue => _rxSettings.value;

  Stream<ErrorCode?> get errorCode => _rxErrorCode.stream;

  Stream<bool> get showDecisiveGradient => _rxShowDecisiveGradient.distinct();

  bool get showDecisiveGradientValue => _rxShowDecisiveGradient.value;

  AutomaticAdvancementController automaticAdvancementController = AutomaticAdvancementController();

  final _rxSettings = BehaviorSubject<TrainJourneySettings>.seeded(TrainJourneySettings());
  final _rxErrorCode = BehaviorSubject<ErrorCode?>.seeded(null);

  final _rxShowDecisiveGradient = BehaviorSubject<bool>.seeded(false);
  Timer? _showDecisiveGradientTimer;

  StreamSubscription? _stateSubscription;
  StreamSubscription? _journeySubscription;

  void _init() {
    _listenToSferaRemoteRepo();
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

  void toggleKmDecisiveGradient() {
    if (!showDecisiveGradientValue) {
      _rxShowDecisiveGradient.add(true);
      _showDecisiveGradientTimer = Timer(Duration(seconds: _resetToKmAfterSeconds), () {
        if (_rxShowDecisiveGradient.value) _rxShowDecisiveGradient.add(false);
      });
    } else {
      _rxShowDecisiveGradient.add(false);
      _showDecisiveGradientTimer?.cancel();
    }
  }

  void onJourneyUpdated(void Function(Journey?) callback) {
    _syncOnJourneyUpdateCallbacks.add(callback);
  }

  void dispose() {
    _rxSettings.close();
    _rxShowDecisiveGradient.close();
    _stateSubscription?.cancel();
    _journeySubscription?.cancel();
    _syncOnJourneyUpdateCallbacks.clear();
    automaticAdvancementController.dispose();
  }

  void _listenToSferaRemoteRepo() {
    _stateSubscription?.cancel();
    _stateSubscription = _sferaRemoteRepo.stateStream.listen((state) {
      switch (state) {
        case SferaRemoteRepositoryState.connected:
          automaticAdvancementController = AutomaticAdvancementController();
          WakelockPlus.enable();
          break;
        case SferaRemoteRepositoryState.connecting:
          _rxErrorCode.add(null);
          break;
        case SferaRemoteRepositoryState.disconnected:
          WakelockPlus.disable();
          _resetSettings();
          if (_sferaRemoteRepo.lastError != null) {
            _rxErrorCode.add(ErrorCode.fromSfera(_sferaRemoteRepo.lastError!));
            setAutomaticAdvancement(false);
          }
          break;
      }
    });
    _journeySubscription = _sferaRemoteRepo.journeyStream.listen((journey) {
      for (final callback in _syncOnJourneyUpdateCallbacks) {
        callback.call(journey);
      }
    });
  }

  void _resetSettings() => _rxSettings.add(TrainJourneySettings());
}

import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_table/journey_table_scroll_controller.dart';
import 'package:app/pages/journey/journey_table/model/journey_advancement_model.dart';
import 'package:app/util/error_code.dart';
import 'package:app/util/time_constants.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final _log = Logger('JourneyTableViewModel');

class JourneyTableViewModel {
  JourneyTableViewModel({
    required SferaRemoteRepo sferaRemoteRepo,
  }) : _sferaRemoteRepo = sferaRemoteRepo {
    _init();
  }

  final _resetToKmAfterSeconds = DI.get<TimeConstants>().kmDecisiveGradientResetSeconds;

  final SferaRemoteRepo _sferaRemoteRepo;

  Stream<Journey?> get journey => _rxJourney.stream;

  Journey? get journeyValue => _rxJourney.value;

  Stream<ErrorCode?> get errorCode => _rxErrorCode.stream;

  Stream<bool> get showDecisiveGradient => _rxShowDecisiveGradient.distinct();

  bool get showDecisiveGradientValue => _rxShowDecisiveGradient.value;

  Stream<bool> get isZenViewMode => _rxZenViewMode.stream;

  bool get isZenViewModeValue => _rxZenViewMode.value;

  JourneyTableScrollController journeyTableScrollController = JourneyTableScrollController();

  final _rxErrorCode = BehaviorSubject<ErrorCode?>.seeded(null);
  final _rxJourney = BehaviorSubject<Journey?>.seeded(null);

  /// Zen mode will hide the AppBar.
  late final _rxZenViewMode = BehaviorSubject<bool>.seeded(true);

  final _rxShowDecisiveGradient = BehaviorSubject<bool>.seeded(false);
  Timer? _showDecisiveGradientTimer;

  StreamSubscription? _stateSubscription;
  StreamSubscription? _journeySubscription;

  void _init() {
    _listenToSferaRemoteRepo();
  }

  void updateZenViewMode(JourneyAdvancementModel journeyAdvancementModel) {
    final newState = journeyAdvancementModel is! Paused;
    _log.fine('ZenViewMode active: $newState}');
    _rxZenViewMode.add(newState);
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

  void dispose() {
    _rxJourney.close();
    _rxZenViewMode.close();
    _rxShowDecisiveGradient.close();
    _rxErrorCode.close();
    _stateSubscription?.cancel();
    _journeySubscription?.cancel();
    journeyTableScrollController.dispose();
  }

  void _listenToSferaRemoteRepo() {
    _stateSubscription?.cancel();
    _stateSubscription = _sferaRemoteRepo.stateStream.listen((state) {
      switch (state) {
        case .connected:
          WakelockPlus.enable();
          break;
        case .connecting:
          _rxErrorCode.add(null);
          break;
        case .disconnected:
          WakelockPlus.disable();
          if (_sferaRemoteRepo.lastError != null) {
            _rxErrorCode.add(.fromSfera(_sferaRemoteRepo.lastError!));
          }
          break;
      }
    });
    _journeySubscription = _sferaRemoteRepo.journeyStream.listen((journey) {
      _rxJourney.add(journey);
    }, onError: _rxJourney.addError);
  }
}

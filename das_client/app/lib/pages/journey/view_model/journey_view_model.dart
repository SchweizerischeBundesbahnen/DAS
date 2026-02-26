import 'dart:async';

import 'package:app/pages/journey/journey_screen/journey_table_scroll_controller.dart';
import 'package:app/util/error_code.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final _log = Logger('JourneyViewModel');

class JourneyViewModel {
  JourneyViewModel({
    required SferaRepository sferaRepository,
  }) : _sferaRepository = sferaRepository {
    _init();
  }

  Stream<Journey?> get journey => _rxJourney.stream;

  Journey? get journeyValue => _rxJourney.value;

  Stream<ErrorCode?> get errorCode => _rxErrorCode.stream;

  JourneyTableScrollController journeyTableScrollController = JourneyTableScrollController();

  final SferaRepository _sferaRepository;
  final _rxErrorCode = BehaviorSubject<ErrorCode?>.seeded(null);
  final _rxJourney = BehaviorSubject<Journey?>.seeded(null);

  StreamSubscription? _sferaRepositoryStateSubscription;
  StreamSubscription? _journeySubscription;

  void dispose() {
    _rxJourney.close();
    _rxErrorCode.close();
    _sferaRepositoryStateSubscription?.cancel();
    _journeySubscription?.cancel();
    journeyTableScrollController.dispose();
  }

  void _init() {
    _initSferaRepositoryStateSubscription();
    _initJourneySubscription();
  }

  void _initSferaRepositoryStateSubscription() {
    _sferaRepositoryStateSubscription?.cancel();
    _sferaRepositoryStateSubscription = _sferaRepository.stateStream.listen((state) {
      switch (state) {
        case .offlineData:
        case .connected:
          WakelockPlus.enable();
          break;
        case .connecting:
          _rxErrorCode.add(null);
          break;
        case .disconnected:
          WakelockPlus.disable();
          if (_sferaRepository.lastError != null) {
            _rxErrorCode.add(.fromSfera(error: _sferaRepository.lastError!));
          }
          break;
      }
    });
  }

  void _initJourneySubscription() {
    _journeySubscription?.cancel();
    _journeySubscription = _sferaRepository.journeyStream.listen(_rxJourney.add, onError: _rxJourney.addError);
  }
}

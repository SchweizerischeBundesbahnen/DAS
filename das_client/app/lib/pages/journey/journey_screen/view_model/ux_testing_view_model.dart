import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/connectivity_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:collection/collection.dart';
import 'package:formation/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class UxTestingViewModel {
  UxTestingViewModel({
    required SferaRepository sferaRepo,
    required RuFeatureProvider ruFeatureProvider,
    required FormationRepository formationRepository,
    required NotificationPriorityQueueViewModel notificationViewModel,
  }) : _sferaRepo = sferaRepo,
       _ruFeatureProvider = ruFeatureProvider,
       _formationRepository = formationRepository,
       _notificationViewModel = notificationViewModel {
    _init();
  }

  final SferaRepository _sferaRepo;
  final RuFeatureProvider _ruFeatureProvider;
  final FormationRepository _formationRepository;
  final NotificationPriorityQueueViewModel _notificationViewModel;

  StreamSubscription? _eventSubscription;
  StreamSubscription? _sferaStateSubscription;

  final _rxUxTestingEvents = BehaviorSubject<UxTestingEvent>();
  final _rxKoaState = BehaviorSubject<KoaState>.seeded(.waitHide);
  final _rxConnectivityDisplayStatus = BehaviorSubject<ConnectivityDisplayStatus?>.seeded(null);

  Stream<KoaState> get koaState => _rxKoaState.distinct();

  Stream<ConnectivityDisplayStatus?> get connectivityDisplayStatus => _rxConnectivityDisplayStatus.stream;

  Stream<UxTestingEvent> get uxTestingEvents => _rxUxTestingEvents.stream;

  Future<bool> get isDepartureProcessFeatureEnabled => _ruFeatureProvider.isRuFeatureEnabled(.departureProcess);

  void dispose() {
    _rxKoaState.close();
    _eventSubscription?.cancel();
    _sferaStateSubscription?.cancel();
  }

  void _init() {
    _eventSubscription = _sferaRepo.uxTestingEventStream.listen((data) async {
      if (data == null) {
        return;
      } else if (data.isKoa) {
        _handleKoaEvent(data);
      } else if (data.isConnectivity) {
        _handleConnectivityEvent(data);
      } else if (data.isFormation) {
        _handleFormationEvent();
      }

      _rxUxTestingEvents.add(data);
    });
    _sferaStateSubscription = _sferaRepo.stateStream.listen((state) {
      if (state == .disconnected) {
        _rxKoaState.add(.waitHide);
      }
    });
  }

  void _handleConnectivityEvent(UxTestingEvent data) =>
      _rxConnectivityDisplayStatus.add(data.toConnectivityDisplayStatus());

  void _handleFormationEvent() {
    final connectedTrain = _sferaRepo.connectedTrain;
    if (connectedTrain != null) {
      _formationRepository.reloadFormation(
        connectedTrain.trainNumber,
        connectedTrain.ru.companyCode,
        connectedTrain.operatingDay ?? connectedTrain.date,
      );
    }
  }

  Future<void> _handleKoaEvent(UxTestingEvent data) async {
    _notificationViewModel.remove(type: .koa);
    final koaEnabled = await _ruFeatureProvider.isRuFeatureEnabled(.koa);
    if (koaEnabled) {
      final koaState = KoaState.from(data.value);

      if (koaState != .waitHide) {
        _notificationViewModel.insert(
          type: .koa,
          callback: koaState == .waitCancelled ? DI.get<DASSounds>().koa.play : null,
        );
      }

      _rxKoaState.add(koaState);
    }
  }
}

extension _UxTestingEventX on UxTestingEvent {
  ConnectivityDisplayStatus? toConnectivityDisplayStatus() {
    var valueToCheck = value;
    if (valueToCheck == 'wifi') valueToCheck = 'connectedWifi';
    return ConnectivityDisplayStatus.values.firstWhereOrNull((status) => status.name == valueToCheck);
  }
}

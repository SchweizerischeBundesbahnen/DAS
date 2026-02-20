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

  void _init() {
    _eventSubscription = _sferaRepo.uxTestingEventStream.listen((data) async {
      if (data != null) {
        if (data.isKoa) {
          final koaEnabled = await _ruFeatureProvider.isRuFeatureEnabled(.koa);
          if (koaEnabled) {
            final koaState = KoaState.from(data.value);

            if (koaState != .waitHide) {
              _notificationViewModel.remove(type: .koaWait);
              _notificationViewModel.remove(type: .koaWaitCancelled);
              final isWaitCancelled = koaState == .waitCancelled;
              _notificationViewModel.insert(
                type: isWaitCancelled ? .koaWaitCancelled : .koaWait,
                callback: isWaitCancelled ? DI.get<DASSounds>().koa.play : null,
              );
            }

            _rxKoaState.add(koaState);
          }
        }

        if (data.isConnectivity) {
          final connectivityDisplayStatus = _connectivityDisplayStatusFromUxTestingEvent(data.value);
          _rxConnectivityDisplayStatus.add(connectivityDisplayStatus);
        }

        if (data.isFormation) {
          final connectedTrain = _sferaRepo.connectedTrain;
          if (connectedTrain != null) {
            _formationRepository.loadFormation(
              connectedTrain.trainNumber,
              connectedTrain.ru.companyCode,
              connectedTrain.operatingDay ?? connectedTrain.date,
            );
          }
        }

        _rxUxTestingEvents.add(data);
      }
    });
    _sferaStateSubscription = _sferaRepo.stateStream.listen((state) {
      if (state == .disconnected) {
        _rxKoaState.add(.waitHide);
      }
    });
  }

  void dispose() {
    _rxKoaState.close();
    _eventSubscription?.cancel();
    _sferaStateSubscription?.cancel();
  }
}

ConnectivityDisplayStatus? _connectivityDisplayStatusFromUxTestingEvent(String value) {
  if (value == 'wifi') value = 'connectedWifi';
  return ConnectivityDisplayStatus.values.firstWhereOrNull((c) => c.name == value);
}

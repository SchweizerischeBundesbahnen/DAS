import 'dart:async';

import 'package:app/provider/ru_feature_provider.dart';
import 'package:customer_oriented_departure/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

// TODO: Move to better location out of view model directory
class SferaMockCustomerOrientedDepartureRepositoryImpl implements CustomerOrientedDepartureRepository {
  SferaMockCustomerOrientedDepartureRepositoryImpl({
    required SferaRepository sferaRepo,
    required RuFeatureProvider ruFeatureProvider,
  }) : _sferaRepo = sferaRepo,
       _ruFeatureProvider = ruFeatureProvider {
    _init();
  }

  final SferaRepository _sferaRepo;
  final RuFeatureProvider _ruFeatureProvider;

  StreamSubscription? _eventSubscription;
  StreamSubscription? _sferaStateSubscription;

  final _rxCustomerOrientedDepartureStatus = BehaviorSubject<CustomerOrientedDepartureStatus>();

  @override
  Stream<CustomerOrientedDepartureStatus> get status => _rxCustomerOrientedDepartureStatus.stream;

  @override
  Future<bool> subscribe({
    required String evu,
    required String trainNumber,
    required DateTime journeyEndTime,
    required bool isDriver,
  }) async {
    return true; // unused
  }

  @override
  Future<bool> unsubscribe({
    required String evu,
    required String trainNumber,
    required DateTime journeyEndTime,
    required bool isDriver,
  }) async {
    return true; // unused
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _sferaStateSubscription?.cancel();
    _sferaStateSubscription = null;
    _rxCustomerOrientedDepartureStatus.close();
  }

  void _init() {
    _eventSubscription = _sferaRepo.uxTestingEventStream.listen((data) async {
      if (data == null || !data.isKoa) return;

      final customerOrientedDepartureEnabled = await _ruFeatureProvider.isRuFeatureEnabled(.customerOrientedDeparture);
      if (customerOrientedDepartureEnabled) {
        final koaState = KoaState.from(data.value);
        _rxCustomerOrientedDepartureStatus.add(koaState.toCustomerOrientedDepartureStatus());
      }
    });

    _sferaStateSubscription = _sferaRepo.stateStream.listen((state) {
      if (state == .disconnected) {
        _rxCustomerOrientedDepartureStatus.add(.departure);
      }
    });
  }
}

extension _KoaStateMapper on KoaState {
  CustomerOrientedDepartureStatus toCustomerOrientedDepartureStatus() => switch (this) {
    KoaState.wait => .wait,
    KoaState.waitCancelled => .ready,
    KoaState.waitHide => .departure,
    KoaState.call => .call,
  };
}

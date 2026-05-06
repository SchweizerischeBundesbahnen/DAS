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

  final _rxCustomerOrientedDepartureStatus = BehaviorSubject<CustomerOrientedDeparture>();
  final _rxJourney = BehaviorSubject<Journey?>.seeded(null);
  final _subscriptions = <StreamSubscription>[];

  @override
  Stream<CustomerOrientedDeparture> get customerOrientedDeparture => _rxCustomerOrientedDepartureStatus.stream;

  @override
  Future<bool> subscribe({
    required String evu,
    required String trainNumber,
    required DateTime? journeyEndTime,
    required bool isDriver,
  }) async {
    return true; // unused
  }

  @override
  Future<bool> unsubscribe() async {
    return true; // unused
  }

  @override
  void dispose() {
    for (final it in _subscriptions) {
      it.cancel();
    }
    _subscriptions.clear();
    _rxCustomerOrientedDepartureStatus.close();
    _rxJourney.close();
  }

  void _init() {
    final eventSubscription = _sferaRepo.uxTestingEventStream.listen((data) async {
      if (data == null || !data.isKoa) return;

      final customerOrientedDepartureEnabled = await _ruFeatureProvider.isRuFeatureEnabled(.customerOrientedDeparture);
      if (customerOrientedDepartureEnabled) {
        _emitStatus(KoaState.from(data.value));
      }
    });
    _subscriptions.add(eventSubscription);

    final sferaStateSubscription = _sferaRepo.stateStream.listen((state) {
      if (state == .disconnected) {
        _emitStatus(.waitHide);
      }
    });
    _subscriptions.add(sferaStateSubscription);

    final journeySubscription = _sferaRepo.journeyStream.listen(_rxJourney.add, onError: _rxJourney.addError);
    _subscriptions.add(journeySubscription);
  }

  void _emitStatus(KoaState koaState) {
    final currentTrain = _rxJourney.value?.metadata.trainIdentification?.trainNumber;
    if (currentTrain != null) {
      _rxCustomerOrientedDepartureStatus.add(koaState.toCustomerOrientedDepartureStatus(trainNumber: currentTrain));
    }
  }
}

extension _KoaStateMapper on KoaState {
  CustomerOrientedDeparture toCustomerOrientedDepartureStatus({required String trainNumber}) => switch (this) {
    KoaState.wait => CustomerOrientedDeparture(trainNumber: trainNumber, status: .wait),
    KoaState.waitCancelled => CustomerOrientedDeparture(trainNumber: trainNumber, status: .ready),
    KoaState.waitHide => CustomerOrientedDeparture(trainNumber: trainNumber, status: .departure),
    KoaState.call => CustomerOrientedDeparture(trainNumber: trainNumber, status: .call),
  };
}

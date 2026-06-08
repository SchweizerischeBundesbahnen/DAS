import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:app/util/app_lifecycle_view_model.dart';
import 'package:auth/component.dart';
import 'package:customer_oriented_departure/component.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('CustomerOrientedDepartureViewModel');

class CustomerOrientedDepartureViewModel extends JourneyAwareViewModel {
  CustomerOrientedDepartureViewModel({
    required this._repository,
    required this._ruFeatureProvider,
    required this._notificationViewModel,
    required this._authenticator,
    required this._appLifecycleViewModel,
    super.journeyViewModel,
  }) {
    _init();
  }

  final CustomerOrientedDepartureRepository _repository;
  final RuFeatureProvider _ruFeatureProvider;
  final NotificationPriorityQueueViewModel _notificationViewModel;
  final AppLifecycleViewModel _appLifecycleViewModel;
  final Authenticator _authenticator;

  final _rxStatus = BehaviorSubject<CustomerOrientedDepartureStatus>.seeded(.departure);
  final _subscriptions = <StreamSubscription>[];

  Journey? _lastJourney;

  Stream<CustomerOrientedDepartureStatus> get status => _rxStatus.stream;

  Future<bool> get isDepartureProcessFeatureEnabled => _ruFeatureProvider.isRuFeatureEnabled(.departureProcess);

  @override
  void onJourneyChanged(Journey? journey) async {
    if (_lastJourney != null) {
      await _unsubscribe();
    }

    if (journey != null) {
      await _subscribe(journey);
    }
    _lastJourney = journey;
  }

  @override
  void dispose() {
    _repository.unsubscribe();
    _rxStatus.close();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }

  Future<void> _subscribe(Journey journey) async {
    final isEnabled = await _ruFeatureProvider.isRuFeatureEnabled(.customerOrientedDeparture);
    if (!isEnabled) return;

    final trainIdentification = journey.metadata.trainIdentification;
    if (trainIdentification == null) {
      _log.warning('Subscribe canceled as journey without train identification was provided');
      return;
    }
    _log.fine('Subscribing to $trainIdentification');

    final endServicePoint = journey.journeyPoints.whereType<ServicePoint>().last;
    final arrivalDepartureTime = endServicePoint.arrivalDepartureTime;
    _repository.subscribe(
      evu: trainIdentification.ru.companyCode,
      trainNumber: trainIdentification.trainNumber,
      journeyEndTime: arrivalDepartureTime?.operationalArrivalTime ?? arrivalDepartureTime?.plannedArrivalTime,
      isDriver: await _isDriver,
    );
  }

  Future<void> _unsubscribe() async {
    _log.fine('Unsubscribing from open customer oriented departure updates.');
    await _repository.unsubscribe();
  }

  Future<bool> get _isDriver async {
    final user = await _authenticator.user();
    return user.roles.contains(Role.driver);
  }

  void _init() {
    _initCustomerOrientedDeparture();
    _initOnResumed();
  }

  void _initOnResumed() {
    final subscription = _appLifecycleViewModel.onResumed.listen((_) {
      _log.fine('App resumed from background. Request latest status');
      _repository.requestLatestStatus();
    });
    _subscriptions.add(subscription);
  }

  void _initCustomerOrientedDeparture() {
    final subscription = _repository.customerOrientedDeparture.listen((event) async {
      final currentTrain = _lastJourney?.metadata.trainIdentification;
      if (currentTrain != null && currentTrain.trainNumber != event.trainNumber) {
        _log.info(
          'Got customer oriented departure event for ${event.trainNumber} that is not for the current train ${currentTrain.trainNumber}.',
        );
        return;
      }

      _notificationViewModel.remove(type: .customerOrientedDeparture);
      final isEnabled = await _ruFeatureProvider.isRuFeatureEnabled(.customerOrientedDeparture);
      if (isEnabled) {
        final status = event.status;
        if (status != .departure) {
          _notificationViewModel.insert(
            type: .customerOrientedDeparture,
            callback: status == .ready ? DI.get<DASSounds>().customerOrientedDeparture.play : null,
          );
        }

        _rxStatus.add(status);
      }
    }, onError: _rxStatus.addError);

    _subscriptions.add(subscription);
  }
}

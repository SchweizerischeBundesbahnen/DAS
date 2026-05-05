import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:auth/component.dart';
import 'package:customer_oriented_departure/component.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('CustomerOrientedDepartureViewModel');

class CustomerOrientedDepartureViewModel extends JourneyAwareViewModel {
  CustomerOrientedDepartureViewModel({
    required CustomerOrientedDepartureRepository repository,
    required RuFeatureProvider ruFeatureProvider,
    required NotificationPriorityQueueViewModel notificationViewModel,
    required Authenticator authenticator,
    super.journeyViewModel,
  }) : _repository = repository,
       _ruFeatureProvider = ruFeatureProvider,
       _notificationViewModel = notificationViewModel,
       _authenticator = authenticator {
    _init();
  }

  final CustomerOrientedDepartureRepository _repository;
  final RuFeatureProvider _ruFeatureProvider;
  final NotificationPriorityQueueViewModel _notificationViewModel;
  final Authenticator _authenticator;

  final _rxStatus = BehaviorSubject<CustomerOrientedDepartureStatus>();
  StreamSubscription? _statusSubscription;

  Journey? _lastJourney;

  Stream<CustomerOrientedDepartureStatus> get status => _rxStatus.stream;

  Future<bool> get isDepartureProcessFeatureEnabled => _ruFeatureProvider.isRuFeatureEnabled(.departureProcess);

  @override
  void journeyIdentificationChanged(Journey? journey) async {
    if (_lastJourney != null) {
      await unsubscribe();
    }

    if (journey != null) {
      await _subscribe(journey);
    }
    _lastJourney = journey;
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _statusSubscription = null;
    _rxStatus.close();
    super.dispose();
  }

  Future<void> _subscribe(Journey journey) async {
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

  Future<void> unsubscribe() async {
    _log.fine('Unsubscribing from open customer oriented departure updates.');
    await _repository.unsubscribe();
  }

  Future<bool> get _isDriver async {
    final user = await _authenticator.user();
    return user.roles.contains(Role.driver);
  }

  void _init() {
    _statusSubscription = _repository.status.listen((status) async {
      _notificationViewModel.remove(type: .customerOrientedDeparture);
      final isEnabled = await _ruFeatureProvider.isRuFeatureEnabled(.customerOrientedDeparture);
      if (isEnabled) {
        if (status != .departure) {
          _notificationViewModel.insert(
            type: .customerOrientedDeparture,
            callback: status == .ready ? DI.get<DASSounds>().customerOrientedDeparture.play : null,
          );
        }

        _rxStatus.add(status);
      }
    }, onError: _rxStatus.addError);
  }
}

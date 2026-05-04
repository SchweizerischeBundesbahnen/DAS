import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:customer_oriented_departure/component.dart';
import 'package:rxdart/rxdart.dart';

class CustomerOrientedDepartureViewModel {
  CustomerOrientedDepartureViewModel({
    required CustomerOrientedDepartureRepository repository,
    required RuFeatureProvider ruFeatureProvider,
    required NotificationPriorityQueueViewModel notificationViewModel,
  }) : _repository = repository,
       _ruFeatureProvider = ruFeatureProvider,
       _notificationViewModel = notificationViewModel {
    _init();
  }

  final CustomerOrientedDepartureRepository _repository;
  final RuFeatureProvider _ruFeatureProvider;
  final NotificationPriorityQueueViewModel _notificationViewModel;

  final _rxStatus = BehaviorSubject<CustomerOrientedDepartureStatus>();
  StreamSubscription? _statusSubscription;

  Stream<CustomerOrientedDepartureStatus> get status => _rxStatus.stream;

  Future<bool> get isDepartureProcessFeatureEnabled => _ruFeatureProvider.isRuFeatureEnabled(.departureProcess);

  void dispose() {
    _statusSubscription?.cancel();
    _statusSubscription = null;
    _rxStatus.close();
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

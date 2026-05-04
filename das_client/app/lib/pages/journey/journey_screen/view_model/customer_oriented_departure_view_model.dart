import 'dart:async';

import 'package:app/provider/ru_feature_provider.dart';
import 'package:customer_oriented_departure/component.dart';
import 'package:rxdart/rxdart.dart';

class CustomerOrientedDepartureViewModel {
  CustomerOrientedDepartureViewModel({
    required CustomerOrientedDepartureRepository repository,
    required RuFeatureProvider ruFeatureProvider,
  }) : _repository = repository,
       _ruFeatureProvider = ruFeatureProvider {
    _init();
  }

  final CustomerOrientedDepartureRepository _repository;
  final RuFeatureProvider _ruFeatureProvider;

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
      final isEnabled = await _ruFeatureProvider.isRuFeatureEnabled(.customerOrientedDeparture);
      if (isEnabled) {
        _rxStatus.add(status);
      }
    }, onError: _rxStatus.addError);
  }
}

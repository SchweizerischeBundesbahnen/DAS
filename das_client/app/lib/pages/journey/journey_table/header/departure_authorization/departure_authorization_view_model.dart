import 'dart:async';

import 'package:app/pages/journey/journey_table/header/departure_authorization/departure_authorization_model.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class DepartureAuthorizationViewModel {
  DepartureAuthorizationViewModel({
    required Stream<Journey?> journeyStream,
    required Stream<JourneyPositionModel> journeyPositionStream,
  }) {
    _initSubscriptions(journeyStream, journeyPositionStream);
  }

  late StreamSubscription<(Journey?, JourneyPositionModel)> _subscription;

  final BehaviorSubject<DepartureAuthorizationModel?> _rxModel = BehaviorSubject.seeded(null);

  Stream<DepartureAuthorizationModel?> get model => _rxModel.stream.distinct();

  DepartureAuthorizationModel? get modelValue => _rxModel.value;

  void dispose() {
    _subscription.cancel();
    _rxModel.close();
  }

  void _initSubscriptions(Stream<Journey?> journeyStream, Stream<JourneyPositionModel> journeyPositionStream) {
    _subscription = CombineLatestStream.combine2(journeyStream, journeyPositionStream, (a, b) => (a, b)).listen((snap) {
      final journey = snap.$1;
      final journeyPosition = snap.$2;

      // TODO: Implement departure authorization model emit logic
    });
  }
}

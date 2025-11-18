import 'dart:async';

import 'package:app/pages/journey/journey_table/header/departure_authorization/departure_authorization_model.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:collection/collection.dart';
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

      if (journey == null) {
        _rxModel.add(null);
        return;
      }

      if (journeyPosition.currentPosition == null) {
        final firstServicePoint = journey.data.whereType<ServicePoint>().firstOrNull;
        _rxModel.add(DepartureAuthorizationModel(servicePoint: firstServicePoint));
        return;
      }

      final passedSignals = journey.data.passedSignalsBetween(
        start: journeyPosition.previousStop,
        end: journeyPosition.currentPosition,
      );

      final relevantServicePoint = passedSignals.anyNonIntermediateSignals()
          ? journeyPosition.nextStop
          : journeyPosition.previousStop;

      _rxModel.add(DepartureAuthorizationModel(servicePoint: relevantServicePoint));
    });
  }
}

// extensions

extension _BaseDataListExtension on List<BaseData> {
  /// returns passed signal between two JourneyPoints. Will return empty list if start or end not given.
  List<Signal> passedSignalsBetween({JourneyPoint? start, JourneyPoint? end}) {
    if (start == null || end == null) return List.empty();
    return whereType<Signal>().where((point) => start.order <= point.order && point.order <= end.order).toList();
  }
}

extension _SignalListExtension on List<Signal> {
  bool anyNonIntermediateSignals() =>
      any((signal) => signal.functions.any((function) => function != SignalFunction.intermediate));
}

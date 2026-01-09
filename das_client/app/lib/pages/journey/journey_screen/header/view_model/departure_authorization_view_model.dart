import 'dart:async';

import 'package:app/pages/journey/journey_screen/header/model/departure_authorization_model.dart';
import 'package:app/pages/journey/journey_screen/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class DepartureAuthorizationViewModel extends JourneyAwareViewModel {
  DepartureAuthorizationViewModel({
    required Stream<JourneyPositionModel> journeyPositionStream,
    super.journeyTableViewModel,
  }) {
    _initSubscriptions(journeyTableViewModel.journey, journeyPositionStream);
  }

  late StreamSubscription<(Journey?, JourneyPositionModel)> _subscription;

  final BehaviorSubject<DepartureAuthorizationModel?> _rxModel = BehaviorSubject.seeded(null);

  Stream<DepartureAuthorizationModel?> get model => _rxModel.stream.distinct();

  DepartureAuthorizationModel? get modelValue => _rxModel.value;

  void _initSubscriptions(Stream<Journey?> journeyStream, Stream<JourneyPositionModel> journeyPositionStream) {
    _subscription = CombineLatestStream.combine2(journeyStream, journeyPositionStream, (a, b) => (a, b)).listen((snap) {
      final journey = snap.$1;
      final journeyPosition = snap.$2;

      if (journey == null) {
        return;
      }

      if (journeyPosition.currentPosition == null) {
        final firstServicePoint = journey.data.whereType<ServicePoint>().firstOrNull;
        _rxModel.add(DepartureAuthorizationModel(servicePoint: firstServicePoint));
        return;
      }

      // Once the first signal after a stop is passed, the departure authorization for the next stop is shown.
      final passedSignals = journey.data.passedSignalsBetween(
        start: journeyPosition.previousStop,
        end: journeyPosition.currentPosition,
      );

      // Intermediate signals are excluded from this logic, since long trains sometimes need to pass them while stopping.
      final relevantServicePoint = passedSignals.anyNonIntermediateSignals()
          ? journeyPosition.nextStop
          : journeyPosition.previousStop;

      _rxModel.add(DepartureAuthorizationModel(servicePoint: relevantServicePoint));
    });
  }

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _rxModel.add(null);
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
    _rxModel.close();
  }
}

extension _BaseDataListExtension on List<BaseData> {
  /// returns passed signal between two JourneyPoints. Will return empty list if start or end not given.
  List<Signal> passedSignalsBetween({JourneyPoint? start, JourneyPoint? end}) {
    if (start == null || end == null) return List.empty();
    return whereType<Signal>().where((point) => start.order <= point.order && point.order <= end.order).toList();
  }
}

extension _SignalListExtension on List<Signal> {
  bool anyNonIntermediateSignals() => any((signal) => signal.functions.any((function) => function != .intermediate));
}

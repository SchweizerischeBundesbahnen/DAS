import 'dart:async';

import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class JourneyPositionViewModel {
  JourneyPositionViewModel({required Stream<Journey?> journeyStream}) {
    _initSubscription(journeyStream);
  }

  StreamSubscription<Journey?>? _journeySubscription;
  final _rxModel = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());

  JourneyPositionModel get modelValue => _rxModel.value;

  Stream<JourneyPositionModel> get model => _rxModel.stream.distinct();

  void dispose() {
    _journeySubscription?.cancel();
    _journeySubscription = null;
  }

  void _initSubscription(Stream<Journey?> journeyStream) {
    _journeySubscription = journeyStream.listen((journey) {
      _rxModel.add(
        JourneyPositionModel(
          currentPosition: journey?.metadata.currentPosition,
          lastServicePoint: journey?.metadata.lastServicePoint,
          lastPosition: journey?.metadata.lastPosition,
        ),
      );
    });
  }
}

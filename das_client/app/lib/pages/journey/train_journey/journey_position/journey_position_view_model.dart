import 'dart:async';

import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class JourneyPositionViewModel {
  JourneyPositionViewModel({required Stream<Journey?> journeyStream}) {
    _initSubscription(journeyStream);
  }

  StreamSubscription<Journey?>? _journeySubscription;
  final _rxCurrentPosition = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());

  JourneyPositionModel get modelValue => _rxCurrentPosition.value;

  Stream<JourneyPositionModel> get currentPosition => _rxCurrentPosition.stream.distinct();

  Future<void> dispose() async {
    await _journeySubscription?.cancel();
    _journeySubscription = null;
  }

  void _initSubscription(Stream<Journey?> journeyStream) {
    _journeySubscription = journeyStream.listen((journey) {
      _rxCurrentPosition.add(JourneyPositionModel(currentPosition: journey?.metadata.currentPosition));
    });
  }
}

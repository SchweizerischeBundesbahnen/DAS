import 'package:app/pages/journey/train_journey/advised_speed/advised_speed_model.dart';
import 'package:app/pages/journey/train_journey/advised_speed/advised_speed_view_model.dart';
import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

void main() {
  group('Unit Test: Advised Speed View Model', () {
    late AdvisedSpeedViewModel testee;
    late BehaviorSubject<Journey?> journeySubject;
    late BehaviorSubject<JourneyPositionModel?> journeyPositionSubject;

    final baseJourney = Journey(
      metadata: Metadata(),
      data: [
        Signal(order: 9, kilometre: []),
        ServicePoint(name: 'B', order: 10, kilometre: []),
        Signal(order: 11, kilometre: []),
        Signal(order: 19, kilometre: []),
        ServicePoint(name: 'C', order: 20, kilometre: []),
        Signal(order: 21, kilometre: []),
        Signal(order: 29, kilometre: []),
        ServicePoint(name: 'D', order: 30, kilometre: []),
        Signal(order: 31, kilometre: []),
      ],
    );

    setUp(() {
      journeySubject = BehaviorSubject<Journey?>.seeded(null);
      journeyPositionSubject = BehaviorSubject<JourneyPositionModel?>.seeded(null);

      testee = AdvisedSpeedViewModel(
        journeyStream: journeySubject.stream,
        journeyPositionStream: journeyPositionSubject,
      );
    });

    test('whenHasNoAdvisedSpeedSegment_doesEmitDefaultInactive', () async {
      expectLater(testee.model, emitsInOrder([AdvisedSpeedModel.inactive()]));

      journeySubject.add(baseJourney);

      await emitObjectToStream(
        journeyPositionSubject,
        JourneyPositionModel(currentPosition: baseJourney.data[1] as JourneyPoint),
      );

      testee.dispose();
    });
  });
}

Future<void> emitObjectToStream<T>(BehaviorSubject<T> subject, T object) async {
  subject.add(object);
  await Future.delayed(const Duration(milliseconds: 10));
}

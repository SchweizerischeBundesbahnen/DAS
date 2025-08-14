import 'dart:async';

import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/train_journey/journey_position/journey_position_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

void main() {
  group('JourneyPositionViewModel unit test', () {
    late JourneyPositionViewModel testee;
    late BehaviorSubject<Journey?> rxMockJourney;
    late List<dynamic> emitRegister;
    late StreamSubscription currentPositionSub;

    setUp(() async {
      rxMockJourney = BehaviorSubject<Journey?>.seeded(null);
      testee = JourneyPositionViewModel(journeyStream: rxMockJourney);
      emitRegister = <dynamic>[];
      currentPositionSub = testee.model.listen(emitRegister.add);

      await _streamProcessing();
    });

    tearDown(() {
      currentPositionSub.cancel();
      emitRegister.clear();
      testee.dispose();
      rxMockJourney.close();
    });

    test('constructor_whenCalled_buildsSubscription', () => expect(rxMockJourney.hasListener, isTrue));

    test('modelValue_whenNoJourney_isEmpty', () {
      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel()));
      expect(emitRegister, hasLength(1));
      expect(emitRegister.first, equals(JourneyPositionModel()));
    });

    test('model_whenJourneyWithNoCurrentPosition_thenIsEmpty', () async {
      // ARRANGE
      rxMockJourney.add(Journey(metadata: Metadata(), data: []));
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel()));
      expect(emitRegister, hasLength(1));
      expect(emitRegister.first, equals(JourneyPositionModel()));
    });

    test('model_whenJourneyWithPosition_thenHasCurrentPosition', () async {
      // ARRANGE
      final signal = Signal(order: 0, kilometre: [0]);
      rxMockJourney.add(
        Journey(
          metadata: Metadata(currentPosition: signal),
          data: [],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel(currentPosition: signal)));
      expect(emitRegister, hasLength(2));
      expect(emitRegister, orderedEquals([JourneyPositionModel(), JourneyPositionModel(currentPosition: signal)]));
    });

    test('model_whenJourneyWithLastServicePoint_thenHasLastServicePoint', () async {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', order: 0, kilometre: []);
      rxMockJourney.add(
        Journey(
          metadata: Metadata(lastServicePoint: aServicePoint),
          data: [],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel(lastServicePoint: aServicePoint)));
      expect(emitRegister, hasLength(2));
      expect(
        emitRegister,
        orderedEquals([JourneyPositionModel(), JourneyPositionModel(lastServicePoint: aServicePoint)]),
      );
    });

    test('model_whenJourneyWithLastPosition_thenHasLastPosition', () async {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', order: 0, kilometre: []);
      rxMockJourney.add(
        Journey(
          metadata: Metadata(lastPosition: aServicePoint),
          data: [],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel(lastPosition: aServicePoint)));
      expect(emitRegister, hasLength(2));
      expect(
        emitRegister,
        orderedEquals([JourneyPositionModel(), JourneyPositionModel(lastPosition: aServicePoint)]),
      );
    });
  });
}

Future<void> _streamProcessing() async => Future.delayed(Duration.zero);

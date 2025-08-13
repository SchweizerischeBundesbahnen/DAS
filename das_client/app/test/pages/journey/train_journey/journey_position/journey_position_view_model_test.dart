import 'dart:async';

import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/train_journey/journey_position/journey_position_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

void main() {
  group('JourneyPositionViewModel unit test', () {
    late JourneyPositionViewModel testee;
    final BehaviorSubject<Journey?> rxMockJourney = BehaviorSubject.seeded(null);
    late List<dynamic> emitRegister;
    late StreamSubscription currentPositionSub;

    setUp(() async {
      testee = JourneyPositionViewModel(journeyStream: rxMockJourney);
      emitRegister = <dynamic>[];
      currentPositionSub = testee.currentPosition.listen(emitRegister.add);

      await _streamProcessing();
    });

    tearDown(() {
      currentPositionSub.cancel();
    });

    test('constructor_whenCalled_buildsSubscription', () => expect(rxMockJourney.hasListener, isTrue));

    test('modelValue_whenNoJourney_isEmpty', () {
      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel()));
      expect(emitRegister, hasLength(1));
      expect(emitRegister.first, equals(JourneyPositionModel()));
    });

    test('model_whenJourneyWithNoPositions_thenIsEmpty', () async {
      // ARRANGE
      rxMockJourney.add(Journey(metadata: Metadata(), data: []));

      await _streamProcessing();
      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel()));
      expect(emitRegister, hasLength(1));
      expect(emitRegister.first, equals(JourneyPositionModel()));
    });

    test('model_whenJourneyWithNonNullPosition_thenIsJourneyPosition', () async {
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
  });
}

Future<void> _streamProcessing() async => Future.delayed(Duration.zero);

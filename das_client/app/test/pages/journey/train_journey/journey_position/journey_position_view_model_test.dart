import 'dart:async';

import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/train_journey/journey_position/journey_position_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

void main() {
  group('JourneyPositionViewModel unit test', () {
    const zeroSignal = Signal(order: 0, kilometre: []);
    const zeroKilometreSignal = Signal(order: 0, kilometre: [1]);
    const tenSignal = Signal(order: 10, kilometre: []);
    const tenKilometreSignal = Signal(order: 10, kilometre: [1]);
    const twentySignal = Signal(order: 20, kilometre: []);

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
      emitRegister.clear();
    });

    tearDown(() {
      currentPositionSub.cancel();
      emitRegister.clear();
      testee.dispose();
      rxMockJourney.close();
    });

    test('constructor_whenCalled_buildsSubscription', () => expect(rxMockJourney.hasListener, isTrue));

    test('modelValue_whenNoJourney_thenIsEmpty', () {
      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel()));
      expect(emitRegister, hasLength(0));
    });

    test('currentPosition_whenEmptyJourneyAndNoSignaledPosition_thenIsEmpty', () async {
      // ARRANGE
      rxMockJourney.add(Journey(metadata: Metadata(), data: []));
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel()));
      expect(emitRegister, hasLength(0));
    });

    test('currentPosition_whenEmptyJourneyAndSignaledPosition_thenIsEmpty', () async {
      // ARRANGE
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 0)),
          data: [],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel()));
      expect(emitRegister, hasLength(0));
    });

    test('currentPosition_whenJourneyAndNoSignaledPosition_thenIsFirst', () async {
      // ARRANGE
      rxMockJourney.add(Journey(metadata: Metadata(), data: [zeroSignal]));
      await _streamProcessing();

      // ACT & EXPECT
      final expectedModel = JourneyPositionModel(currentPosition: zeroSignal);
      expect(testee.modelValue, equals(expectedModel));
      expect(emitRegister, hasLength(1));
      expect(emitRegister.first, equals(expectedModel));
    });

    test('currentPosition_whenJourneyAndSignaledPositionBeforeFirstPoint_thenIsNull', () async {
      // ARRANGE
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 0)),
          data: [tenSignal],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel()));
      expect(emitRegister, hasLength(0));
    });

    test('currentPosition_whenJourneyAndSignaledPositionOnPoint_thenReturnsPoint', () async {
      // ARRANGE
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
          data: [tenSignal],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel(currentPosition: tenSignal)));
      expect(emitRegister, hasLength(1));
    });

    test('currentPosition_whenJourneyUpdatedWithDifferentPointSameOrder_thenReturnsDifferentPoint', () async {
      // ARRANGE
      final aJourney = Journey(
        metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
        data: [tenSignal],
      );
      final a1Journey = Journey(
        metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
        data: [tenKilometreSignal],
      );
      rxMockJourney.add(aJourney);
      rxMockJourney.add(a1Journey);
      await _streamProcessing();

      // ACT & EXPECT
      expect(
        emitRegister,
        orderedEquals([
          JourneyPositionModel(currentPosition: tenSignal, lastPosition: null),
          JourneyPositionModel(currentPosition: tenKilometreSignal, lastPosition: tenKilometreSignal),
        ]),
      );
    });

    test('currentPosition_whenJourneyAndSignaledPositionAfterPoint_thenReturnsPointBefore', () async {
      // ARRANGE
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 15)),
          data: [zeroSignal, tenSignal, twentySignal],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel(currentPosition: tenSignal)));
      expect(emitRegister, hasLength(1));
    });

    test('lastPosition_whenSingleJourney_thenReturnsNull', () async {
      // ARRANGE
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
          data: [zeroSignal],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel(currentPosition: zeroSignal, lastPosition: null)));
      expect(emitRegister, hasLength(1));
    });

    test('lastPosition_whenJourneyUpdatedWithSameCurrentPosition_thenReturnsLastPosition', () async {
      // ARRANGE
      final aJourney = Journey(
        metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
        data: [tenSignal],
      );
      rxMockJourney.add(aJourney);
      rxMockJourney.add(aJourney);
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel(currentPosition: tenSignal, lastPosition: tenSignal)));
      expect(emitRegister, hasLength(2));
      expect(
        emitRegister,
        orderedEquals([
          JourneyPositionModel(currentPosition: tenSignal, lastPosition: null),
          JourneyPositionModel(currentPosition: tenSignal, lastPosition: tenSignal),
        ]),
      );
    });

    test('lastPosition_whenJourneyUpdatedWithDifferentCurrentPosition_thenReturnsCorrectLastPosition', () async {
      // ARRANGE
      final aJourney = Journey(
        metadata: Metadata(),
        data: [zeroSignal],
      );
      final bJourney = Journey(
        metadata: Metadata(signaledPosition: SignaledPosition(order: 15)),
        data: [zeroSignal, tenSignal],
      );
      rxMockJourney.add(aJourney);
      rxMockJourney.add(bJourney);
      await _streamProcessing();

      // ACT & EXPECT
      expect(emitRegister, hasLength(2));
      expect(
        emitRegister,
        orderedEquals([
          JourneyPositionModel(currentPosition: zeroSignal, lastPosition: null),
          JourneyPositionModel(currentPosition: tenSignal, lastPosition: zeroSignal),
        ]),
      );
    });

    test(
      'lastPosition_whenJourneyUpdatedWithDifferentValuesAndCurrentPosition_thenReturnsCorrectLastPosition',
      () async {
        // ARRANGE
        final aJourney = Journey(
          metadata: Metadata(),
          data: [zeroSignal],
        );
        final bJourney = Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 15)),
          data: [zeroKilometreSignal, tenSignal],
        );
        rxMockJourney.add(aJourney);
        rxMockJourney.add(bJourney);
        await _streamProcessing();

        // ACT & EXPECT
        expect(
          emitRegister,
          orderedEquals([
            JourneyPositionModel(currentPosition: zeroSignal, lastPosition: null),
            JourneyPositionModel(currentPosition: tenSignal, lastPosition: zeroKilometreSignal),
          ]),
        );
      },
    );

    test('previousServicePoint_whenNoServicePoints_isNull', () async {
      // ARRANGE
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 0)),
          data: [zeroSignal],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue.previousServicePoint, isNull);
    });

    test('previousServicePoint_whenNoServicePointBeforeCurrentPosition_isNull', () async {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', order: 10, kilometre: []);
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 0)),
          data: [zeroSignal, aServicePoint],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue.previousServicePoint, isNull);
    });

    test('previousServicePoint_whenCurrentPositionIsServicePoint_thenIsThisServicePoint', () async {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', order: 10, kilometre: []);
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
          data: [zeroSignal, aServicePoint],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue.previousServicePoint, equals(aServicePoint));
    });

    test('previousServicePoint_whenCurrentPositionIsAfterServicePoint_thenIsThisServicePoint', () async {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', order: 10, kilometre: []);
      final bServicePoint = ServicePoint(name: 'b', order: 15, kilometre: []);
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
          data: [zeroSignal, aServicePoint, bServicePoint, twentySignal],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue.previousServicePoint, equals(bServicePoint));
    });

    test('nextServicePoint_whenHasNoServicePoints_thenIsNull', () async {
      // ARRANGE
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
          data: [zeroSignal, twentySignal],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue.nextServicePoint, isNull);
    });

    test('nextServicePoint_whenIsOnServicePointAndNoOther_thenIsNull', () async {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', order: 20, kilometre: []);
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
          data: [zeroSignal, tenSignal, aServicePoint],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue.nextServicePoint, isNull);
    });

    test('nextServicePoint_whenIsOnServicePointAndHasOther_thenIsOther', () async {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', order: 20, kilometre: []);
      final bServicePoint = ServicePoint(name: 'b', order: 25, kilometre: []);
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
          data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue.nextServicePoint, equals(bServicePoint));
    });

    test('nextStop_whenHasNoServicePoints_thenIsNull', () async {
      // ARRANGE
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
          data: [zeroSignal, twentySignal],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue.nextStop, isNull);
    });

    test('nextStop_whenIsOnServicePointAndNoOther_thenIsNull', () async {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', order: 20, kilometre: []);
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
          data: [zeroSignal, tenSignal, aServicePoint],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue.nextStop, isNull);
    });

    test('nextStop_whenIsOnServicePointAndHasOtherThatIsNoStop_thenIsNull', () async {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', order: 20, kilometre: [], isStop: true);
      final bServicePoint = ServicePoint(name: 'b', order: 25, kilometre: []);
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
          data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue.nextStop, isNull);
    });

    test('nextStop_whenIsOnServicePointAndHasOtherThatIsStop_thenIsOther', () async {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', order: 20, kilometre: [], isStop: true);
      final bServicePoint = ServicePoint(name: 'b', order: 25, kilometre: [], isStop: true);
      rxMockJourney.add(
        Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
          data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
        ),
      );
      await _streamProcessing();

      // ACT & EXPECT
      expect(testee.modelValue.nextStop, equals(bServicePoint));
    });
  });
}

Future<void> _streamProcessing() async => Future.delayed(Duration.zero);

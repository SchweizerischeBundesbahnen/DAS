import 'dart:async';

import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_table/punctuality/punctuality_model.dart';
import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
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
    late BehaviorSubject<PunctualityModel> rxMockPunctuality;
    late List<dynamic> emitRegister;
    late StreamSubscription currentPositionSub;
    late FakeAsync testAsync;
    late Clock now;

    setUp(() {
      now = Clock(() => DateTime(1970));
      withClock(now, () {
        fakeAsync((fakeAsync) {
          rxMockJourney = BehaviorSubject<Journey?>.seeded(null);
          rxMockPunctuality = BehaviorSubject<PunctualityModel>.seeded(PunctualityModel.hidden());
          testAsync = fakeAsync;
          testee = JourneyPositionViewModel(journeyStream: rxMockJourney, punctualityStream: rxMockPunctuality);
          emitRegister = <dynamic>[];
          currentPositionSub = testee.model.listen(emitRegister.add);
          _processStreamInFakeAsync(fakeAsync);
        });
      });

      _processStreamInFakeAsync(testAsync);
      emitRegister.clear();
    });

    tearDown(() {
      currentPositionSub.cancel();
      emitRegister.clear();
      testee.dispose();
      rxMockJourney.close();
    });

    test('constructor_whenCalled_buildsSubscription', () => expect(rxMockJourney.hasListener, isTrue));

    group('expect empty journey position model', () {
      test('modelValue_whenNoJourney_thenIsEmpty', () {
        // ACT & EXPECT
        expect(testee.modelValue, equals(JourneyPositionModel()));
        expect(emitRegister, hasLength(0));
      });

      test('currentPosition_whenEmptyJourneyAndNoSignaledPosition_thenIsEmpty', () {
        // ARRANGE
        testAsync.run((_) {
          rxMockJourney.add(Journey(metadata: Metadata(), data: []));
        });
        _processStreamInFakeAsync(testAsync);

        // ACT & EXPECT
        expect(testee.modelValue, equals(JourneyPositionModel()));
        expect(emitRegister, hasLength(0));
      });

      test('currentPosition_whenEmptyJourneyAndSignaledPosition_thenIsEmpty', () {
        // ARRANGE
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 0)),
              data: [],
            ),
          );
        });
        _processStreamInFakeAsync(testAsync);

        // ACT & EXPECT
        expect(testee.modelValue, equals(JourneyPositionModel()));
        expect(emitRegister, hasLength(0));
      });

      test('currentPosition_whenSignaledPositionBeforeFirstPoint_thenIsNull', () {
        // ARRANGE
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 0)),
              data: [tenSignal],
            ),
          );
        });
        _processStreamInFakeAsync(testAsync);

        // ACT & EXPECT
        expect(testee.modelValue, equals(JourneyPositionModel()));
        expect(emitRegister, hasLength(0));
      });
    });

    test('currentPosition_whenNoSignaledPositionAndNoManualPosition_thenIsFirst', () {
      // ARRANGE
      testAsync.run((_) {
        rxMockJourney.add(Journey(metadata: Metadata(), data: [zeroSignal]));
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      final expectedModel = JourneyPositionModel(currentPosition: zeroSignal);
      expect(testee.modelValue, equals(expectedModel));
      expect(emitRegister, hasLength(1));
      expect(emitRegister.first, equals(expectedModel));
    });

    test('currentPosition_whenNoSignaledPositionButManualPosition_thenIsManualPosition', () {
      testAsync.run((_) {
        rxMockJourney.add(Journey(metadata: Metadata(), data: [zeroSignal]));
        _processStreamInFakeAsync(testAsync);
      });
      emitRegister.clear();

      // ACT
      testAsync.run((_) {
        testee.setManualPosition(zeroSignal);
        _processStreamInFakeAsync(testAsync);
      });

      // EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel(currentPosition: zeroSignal, lastPosition: zeroSignal)));
      expect(emitRegister, hasLength(1));
    });

    test('currentPosition_whenSignaledPositionOnPoint_thenReturnsPoint', () {
      // ARRANGE
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
            data: [tenSignal],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel(currentPosition: tenSignal)));
      expect(emitRegister, hasLength(1));
    });

    test('currentPosition_whenJourneyUpdatedWithDifferentPointSameOrder_thenReturnsDifferentPoint', () {
      // ARRANGE
      final aJourney = Journey(
        metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
        data: [tenSignal],
      );
      final a1Journey = Journey(
        metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
        data: [tenKilometreSignal],
      );
      testAsync.run((_) {
        rxMockJourney.add(aJourney);
        _processStreamInFakeAsync(testAsync);
        rxMockJourney.add(a1Journey);
        _processStreamInFakeAsync(testAsync);
      });

      // ACT & EXPECT
      expect(
        emitRegister,
        orderedEquals([
          JourneyPositionModel(currentPosition: tenSignal, lastPosition: null),
          JourneyPositionModel(currentPosition: tenKilometreSignal, lastPosition: tenKilometreSignal),
        ]),
      );
    });

    test('currentPosition_whenSignaledPositionAfterPoint_thenReturnsPointBefore', () {
      // ARRANGE
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 15)),
            data: [zeroSignal, tenSignal, twentySignal],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel(currentPosition: tenSignal)));
      expect(emitRegister, hasLength(1));
    });

    test('currentPosition_afterSetManualPositionThenJourneyUpdate_movesToJourneyUpdatePosition', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 20, kilometre: [], isStop: true);
      final bServicePoint = ServicePoint(name: 'b', abbreviation: '', order: 25, kilometre: [], isStop: true);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
            data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
          ),
        );
        _processStreamInFakeAsync(testAsync);
        testee.setManualPosition(aServicePoint);
      });
      _processStreamInFakeAsync(testAsync);
      expect(testee.modelValue.currentPosition, equals(aServicePoint));

      // ACT
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 25)),
            data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(testee.modelValue.currentPosition, equals(bServicePoint));
    });

    /// TMS VAD cannot send updates for arriving at an actual service point, but only sends an event for the previous
    /// signal (usually an entry signal).
    ///
    /// To be able to update the location to the service point nevertheless, we use the operational arrival time, the
    /// current time and the reported delay to move the current position to the service point once the train has
    /// theoretically reached the service point.
    group('timed service point advancements', () {
      test('currentPosition_whenHasNoPunctuality_thenReturnsPointBeforeSP', () {
        // ARRANGE
        final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 16, kilometre: []);
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 15)),
              data: [zeroSignal, tenSignal, aServicePoint, twentySignal],
            ),
          );
        });
        _processStreamInFakeAsync(testAsync);

        // ACT & EXPECT
        expect(
          testee.modelValue,
          equals(JourneyPositionModel(currentPosition: tenSignal, nextServicePoint: aServicePoint)),
        );
        expect(emitRegister, hasLength(1));
      });

      test('currentPosition_whenSPWithoutOperationalArrivalTime_thenReturnsPointBeforeSP', () {
        // ARRANGE
        final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 16, kilometre: []);
        testAsync.run((_) {
          rxMockPunctuality.add(
            PunctualityModel.visible(
              delay: Delay(value: Duration.zero, location: ''),
            ),
          );
          _processStreamInFakeAsync(testAsync);
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 15)),
              data: [zeroSignal, tenSignal, aServicePoint, twentySignal],
            ),
          );
        });
        _processStreamInFakeAsync(testAsync);

        // ACT & EXPECT
        expect(
          testee.modelValue,
          equals(JourneyPositionModel(currentPosition: tenSignal, nextServicePoint: aServicePoint)),
        );
        expect(emitRegister, hasLength(1));
      });

      test('currentPosition_whenSPWithArrivalTimeAndNoDelay_thenSetsToSPAfterTimer', () {
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          order: 16,
          kilometre: [],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().add(Duration(seconds: 30)),
            ambiguousArrivalTime: now.now().add(Duration(seconds: 50)),
          ),
        );

        testAsync.run((_) {
          rxMockPunctuality.add(
            PunctualityModel.visible(
              delay: Delay(value: Duration.zero, location: ''),
            ),
          );
          _processStreamInFakeAsync(testAsync);
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
              data: [zeroSignal, tenSignal, aServicePoint, twentySignal],
            ),
          );
        });
        _processStreamInFakeAsync(testAsync);

        testAsync.elapse(Duration(seconds: 51));

        _processStreamInFakeAsync(testAsync);

        expect(
          emitRegister,
          orderedEquals([
            JourneyPositionModel(currentPosition: tenSignal, nextServicePoint: aServicePoint),
            JourneyPositionModel(
              currentPosition: aServicePoint,
              previousServicePoint: aServicePoint,
              lastPosition: tenSignal,
            ),
          ]),
        );
        expect(emitRegister, hasLength(2));
      });

      test('currentPosition_whenSPWithArrivalTimeAndPositiveDelay_thenReturnsSPAfterTimerWithDelay', () {
        final now = DateTime(1970);
        final clock = Clock(() => now);

        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          order: 16,
          kilometre: [],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.add(Duration(seconds: 30)),
            ambiguousArrivalTime: now.add(Duration(seconds: 50)),
          ),
        );

        testAsync.run((_) {
          withClock(clock, () {
            rxMockPunctuality.add(
              PunctualityModel.visible(
                delay: Delay(value: Duration(minutes: 1), location: ''),
              ),
            );
            _processStreamInFakeAsync(testAsync);
            rxMockJourney.add(
              Journey(
                metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
                data: [zeroSignal, tenSignal, aServicePoint, twentySignal],
              ),
            );
          });
        });
        _processStreamInFakeAsync(testAsync);

        testAsync.elapse(Duration(seconds: 111));

        _processStreamInFakeAsync(testAsync);

        expect(
          emitRegister,
          orderedEquals([
            JourneyPositionModel(currentPosition: tenSignal, nextServicePoint: aServicePoint),
            JourneyPositionModel(
              currentPosition: aServicePoint,
              previousServicePoint: aServicePoint,
              lastPosition: tenSignal,
            ),
          ]),
        );
        expect(emitRegister, hasLength(2));
      });

      test('currentPosition_whenSPWithArrivalTimeAndNegativeDelay_thenCurrentPositionIsDirectlySP', () {
        final now = DateTime(1970);
        final clock = Clock(() => now);

        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          order: 16,
          kilometre: [],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.add(Duration(seconds: 30)),
            ambiguousArrivalTime: now.add(Duration(seconds: 50)),
          ),
        );
        withClock(clock, () {
          testAsync.run((_) {
            rxMockPunctuality.add(
              PunctualityModel.visible(
                delay: Delay(value: Duration(minutes: -1), location: ''),
              ),
            );
            rxMockJourney.add(
              Journey(
                metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
                data: [zeroSignal, tenSignal, aServicePoint, twentySignal],
              ),
            );
          });
        });
        _processStreamInFakeAsync(testAsync);
        expect(
          emitRegister,
          orderedEquals([
            JourneyPositionModel(currentPosition: tenSignal, nextServicePoint: aServicePoint),
            JourneyPositionModel(currentPosition: aServicePoint, previousServicePoint: aServicePoint),
          ]),
        );
        expect(emitRegister, hasLength(2));
      });
    });

    test('lastPosition_whenSingleJourney_thenReturnsNull', () {
      // ARRANGE
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
            data: [zeroSignal],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue, equals(JourneyPositionModel(currentPosition: zeroSignal, lastPosition: null)));
      expect(emitRegister, hasLength(1));
    });

    test('lastPosition_whenJourneyUpdatedWithSameCurrentPosition_thenReturnsLastPosition', () {
      // ARRANGE
      final aJourney = Journey(
        metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
        data: [tenSignal],
      );
      testAsync.run((_) {
        rxMockJourney.add(aJourney);
        _processStreamInFakeAsync(testAsync);
        rxMockJourney.add(aJourney);
        _processStreamInFakeAsync(testAsync);
      });

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

    test('lastPosition_whenJourneyUpdatedWithDifferentCurrentPosition_thenReturnsCorrectLastPosition', () {
      // ARRANGE
      final aJourney = Journey(
        metadata: Metadata(),
        data: [zeroSignal],
      );
      final bJourney = Journey(
        metadata: Metadata(signaledPosition: SignaledPosition(order: 15)),
        data: [zeroSignal, tenSignal],
      );
      testAsync.run((_) {
        rxMockJourney.add(aJourney);
        _processStreamInFakeAsync(testAsync);
        rxMockJourney.add(bJourney);
        _processStreamInFakeAsync(testAsync);
      });

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
      () {
        // ARRANGE
        final aJourney = Journey(
          metadata: Metadata(),
          data: [zeroSignal],
        );
        final bJourney = Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 15)),
          data: [zeroKilometreSignal, tenSignal],
        );
        testAsync.run((_) {
          rxMockJourney.add(aJourney);
          _processStreamInFakeAsync(testAsync);
          rxMockJourney.add(bJourney);
          _processStreamInFakeAsync(testAsync);
        });

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

    test('previousServicePoint_whenNoServicePoints_isNull', () {
      // ARRANGE
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 0)),
            data: [zeroSignal],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.previousServicePoint, isNull);
    });

    test('previousServicePoint_whenNoServicePointBeforeCurrentPosition_isNull', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 10, kilometre: []);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 0)),
            data: [zeroSignal, aServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.previousServicePoint, isNull);
    });

    test('previousServicePoint_whenCurrentPositionIsServicePoint_thenIsThisServicePoint', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 10, kilometre: []);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
            data: [zeroSignal, aServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.previousServicePoint, equals(aServicePoint));
    });

    test('previousServicePoint_whenCurrentPositionIsAfterServicePoint_thenIsThisServicePoint', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 10, kilometre: []);
      final bServicePoint = ServicePoint(name: 'b', abbreviation: '', order: 15, kilometre: []);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
            data: [zeroSignal, aServicePoint, bServicePoint, twentySignal],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.previousServicePoint, equals(bServicePoint));
    });

    test('nextServicePoint_whenHasNoServicePoints_thenIsNull', () {
      // ARRANGE
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
            data: [zeroSignal, twentySignal],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.nextServicePoint, isNull);
    });

    test('nextServicePoint_whenIsOnServicePointAndNoOther_thenIsNull', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 20, kilometre: []);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
            data: [zeroSignal, tenSignal, aServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.nextServicePoint, isNull);
    });

    test('nextServicePoint_whenIsOnServicePointAndHasOther_thenIsOther', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 20, kilometre: []);
      final bServicePoint = ServicePoint(name: 'b', abbreviation: '', order: 25, kilometre: []);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
            data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.nextServicePoint, equals(bServicePoint));
    });

    test('previousStop_whenHasNoServicePoints_thenIsNull', () {
      // ARRANGE
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
            data: [zeroSignal, twentySignal],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.previousStop, isNull);
    });

    test('previousStop_whenIsOnServicePointThatIsNoStop_thenIsNull', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 20, kilometre: []);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
            data: [zeroSignal, tenSignal, aServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.previousStop, isNull);
    });

    test('previousStop_whenIsOnServicePointThatIsStopAndNoOther_thenIsThisServicePoint', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 20, kilometre: [], isStop: true);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
            data: [zeroSignal, tenSignal, aServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.previousStop, equals(aServicePoint));
    });

    test('previousStop_whenIsOnServicePointAndFutureOtherThatIsStop_thenIsCurrentOne', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 20, kilometre: [], isStop: true);
      final bServicePoint = ServicePoint(name: 'b', abbreviation: '', order: 25, kilometre: [], isStop: true);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
            data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.previousStop, equals(aServicePoint));
    });

    test('previousStop_whenIsOnServicePointAndHasPastOtherThatIsStop_thenIsCurrentOne', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 20, kilometre: [], isStop: true);
      final bServicePoint = ServicePoint(name: 'b', abbreviation: '', order: 25, kilometre: [], isStop: true);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 25)),
            data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.previousStop, equals(bServicePoint));
    });

    test('nextStop_whenHasNoServicePoints_thenIsNull', () {
      // ARRANGE
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
            data: [zeroSignal, twentySignal],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.nextStop, isNull);
    });

    test('nextStop_whenIsOnServicePointAndNoOther_thenIsNull', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 20, kilometre: []);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
            data: [zeroSignal, tenSignal, aServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.nextStop, isNull);
    });

    test('nextStop_whenIsOnServicePointAndHasOtherThatIsNoStop_thenIsNull', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 20, kilometre: [], isStop: true);
      final bServicePoint = ServicePoint(name: 'b', abbreviation: '', order: 25, kilometre: []);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
            data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
          ),
        );
        _processStreamInFakeAsync(testAsync);
      });

      // ACT & EXPECT
      expect(testee.modelValue.nextStop, isNull);
    });

    test('nextStop_whenIsOnServicePointAndHasOtherThatIsStop_thenIsOther', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 20, kilometre: [], isStop: true);
      final bServicePoint = ServicePoint(name: 'b', abbreviation: '', order: 25, kilometre: [], isStop: true);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
            data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);

      // ACT & EXPECT
      expect(testee.modelValue.nextStop, equals(bServicePoint));
    });

    test('setManualPosition_whenHasNoSignaledPosition_thenMovesCurrentAndLastPosition', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 20, kilometre: [], isStop: true);
      final bServicePoint = ServicePoint(name: 'b', abbreviation: '', order: 25, kilometre: [], isStop: true);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(),
            data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);
      expect(testee.modelValue.currentPosition, equals(zeroSignal));

      // ACT
      testAsync.run((async) {
        testee.setManualPosition(aServicePoint);
        _processStreamInFakeAsync(async);
      });

      // EXPECT
      expect(testee.modelValue.currentPosition, equals(aServicePoint));
      expect(testee.modelValue.lastPosition, equals(zeroSignal));
    });

    test('setManualPosition_whenHasSignaledPosition_thenMovesToNewPosition', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 20, kilometre: [], isStop: true);
      final bServicePoint = ServicePoint(name: 'b', abbreviation: '', order: 25, kilometre: [], isStop: true);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 25)),
            data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);
      expect(testee.modelValue.currentPosition, equals(bServicePoint));

      // ACT
      testAsync.run((async) {
        testee.setManualPosition(aServicePoint);
        _processStreamInFakeAsync(async);
      });

      // EXPECT
      expect(testee.modelValue.currentPosition, equals(aServicePoint));
      expect(testee.modelValue.lastPosition, equals(bServicePoint));
    });

    test('setManualPosition_whenCalledTwiceWithSamePosition_thenMovesToManualPositionOnce', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 20, kilometre: [], isStop: true);
      final bServicePoint = ServicePoint(name: 'b', abbreviation: '', order: 25, kilometre: [], isStop: true);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 25)),
            data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);
      expect(testee.modelValue.currentPosition, equals(bServicePoint));

      // ACT
      testAsync.run((async) {
        testee.setManualPosition(aServicePoint);
        _processStreamInFakeAsync(async);
        testee.setManualPosition(aServicePoint);
        _processStreamInFakeAsync(async);
      });

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(testee.modelValue.currentPosition, equals(aServicePoint));
      expect(testee.modelValue.lastPosition, equals(bServicePoint));
    });

    test('setManualPosition_whenIsGivenNullPosition_thenMovesToSignaledPosition', () {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'a', abbreviation: '', order: 20, kilometre: [], isStop: true);
      final bServicePoint = ServicePoint(name: 'b', abbreviation: '', order: 25, kilometre: [], isStop: true);
      testAsync.run((_) {
        rxMockJourney.add(
          Journey(
            metadata: Metadata(signaledPosition: SignaledPosition(order: 25)),
            data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
          ),
        );
      });
      _processStreamInFakeAsync(testAsync);
      expect(testee.modelValue.currentPosition, equals(bServicePoint));

      testAsync.run((async) {
        testee.setManualPosition(aServicePoint);
        _processStreamInFakeAsync(async);
      });

      expect(testee.modelValue.currentPosition, equals(aServicePoint));
      expect(testee.modelValue.lastPosition, equals(bServicePoint));

      // ACT
      testAsync.run((_) {
        testee.setManualPosition(null);
        _processStreamInFakeAsync(testAsync);
      });

      expect(testee.modelValue.currentPosition, equals(bServicePoint));
      expect(testee.modelValue.lastPosition, equals(aServicePoint));
    });
  });
}

void _processStreamInFakeAsync(FakeAsync testAsync) => testAsync.elapse(const Duration(milliseconds: 5));

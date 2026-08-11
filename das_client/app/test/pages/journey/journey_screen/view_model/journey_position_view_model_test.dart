import 'dart:async';
import 'dart:collection';

import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/delay_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_advancement_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/provider/timed_route_provider_impl.dart';
import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import 'journey_position_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<JourneyViewModel>()])
void main() {
  group('JourneyPositionViewModel unit test', () {
    const zeroSignal = Signal(order: 0, kilometre: []);
    const zeroKilometreSignal = Signal(order: 0, kilometre: [1]);
    const tenSignal = Signal(order: 10, kilometre: []);
    const tenKilometreSignal = Signal(order: 10, kilometre: [1]);
    const twentySignal = Signal(order: 20, kilometre: []);

    late JourneyPositionViewModel testee;
    late JourneySettingsViewModel journeySettingsViewModel;
    late MockJourneyViewModel mockJourneyViewModel;
    late BehaviorSubject<Journey?> rxMockJourney;
    late BehaviorSubject<DelayModel> rxMockPunctuality;
    late List<dynamic> emitRegister;
    late StreamSubscription currentPositionSub;
    late FakeAsync testAsync;
    late Clock now;

    setUp(() {
      now = Clock(() => DateTime(1970));
      withClock(now, () {
        fakeAsync((fakeAsync) {
          mockJourneyViewModel = MockJourneyViewModel();
          when(mockJourneyViewModel.journey).thenAnswer((_) => rxMockJourney.stream);
          rxMockJourney = BehaviorSubject<Journey?>.seeded(null);
          rxMockPunctuality = BehaviorSubject<DelayModel>.seeded(DelayModel.hidden());
          journeySettingsViewModel = JourneySettingsViewModel(journeyViewModel: mockJourneyViewModel);
          testAsync = fakeAsync;
          testee = JourneyPositionViewModel(
            journeyViewModel: mockJourneyViewModel,
            punctualityStream: rxMockPunctuality,
            journeySettingsViewModel: journeySettingsViewModel,
            timedRouteProvider: TimedRouteProviderImpl(),
          );
          emitRegister = <dynamic>[];
          currentPositionSub = testee.model.listen(emitRegister.add);
          fakeAsync.flushMicrotasks();
        });
      });

      testAsync.flushMicrotasks();
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
        testAsync.flushMicrotasks();

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
        testAsync.flushMicrotasks();

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
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue, equals(JourneyPositionModel()));
        expect(emitRegister, hasLength(0));
      });
    });

    group('currentPosition calculation', () {
      test('currentPosition_whenNoSignaledPositionAndNoManualPosition_thenIsFirst', () {
        // ARRANGE
        testAsync.run((_) {
          rxMockJourney.add(Journey(metadata: Metadata(), data: [zeroSignal]));
        });
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        final expectedModel = JourneyPositionModel(currentPosition: zeroSignal);
        expect(testee.modelValue, equals(expectedModel));
        expect(emitRegister, hasLength(1));
        expect(emitRegister.first, equals(expectedModel));
      });

      test('currentPosition_whenSignaledPositionOnSignal_thenReturnsSignal', () {
        // ARRANGE
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
              data: [tenSignal],
            ),
          );
        });
        testAsync.flushMicrotasks();

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
          testAsync.flushMicrotasks();
          rxMockJourney.add(a1Journey);
          testAsync.flushMicrotasks();
        });

        // ACT & EXPECT
        expect(
          emitRegister,
          orderedEquals([
            JourneyPositionModel(currentPosition: tenSignal, lastPosition: null),
            JourneyPositionModel(currentPosition: tenKilometreSignal, lastPosition: null),
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
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue, equals(JourneyPositionModel(currentPosition: tenSignal)));
        expect(emitRegister, hasLength(1));
      });

      test('currentPosition_whenSignalAndServicePointOnSameOrder_thenPrefersSignal', () {
        // ARRANGE
        final aServicePoint = ServicePoint(name: 'a', abbreviation: '', locationCode: '', order: 10, kilometre: []);
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
              data: [zeroSignal, aServicePoint, tenSignal],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue.currentPosition, equals(tenSignal));
        expect(emitRegister, hasLength(1));
      });
    });

    /// TMS VAD cannot send updates for arriving at an actual service point, but only sends an event for the previous
    /// signal (usually an entry signal).
    ///
    /// To be able to update the location to the service point nevertheless, we use the best known arrival time, the
    /// current time and the reported delay to move the current position to the service point once the train has
    /// theoretically reached the service point.
    ///
    /// Which time sources exist depends on the train category:
    /// * Cargo, empty material and short-term (<2h before departure) journeys: planned and operational times
    ///   (forecast recalculated at every signal), but never VPro speeds or PüA reports.
    /// * Passenger trains: planned and operational times, VPro speeds and PüA reports at every signal.
    /// * Diverted passenger trains: like cargo on the diverted section, like passenger trains on the rest.
    /// * Only planned times (no operational times) exist for journeys starting abroad and for cargo/empty material
    ///   journeys started >4h early, in both cases until the first CH signal is passed.
    ///
    /// With a VPro speed a fresh PüA is required: on stale or missing PüA the advancement waits for the next
    /// signal instead.
    group('timed service point advancements', () {
      test('currentPosition_whenSPWithoutArrivalTime_thenReturnsPointBeforeSPAndDoesNotTimeAdvance', () {
        // ARRANGE
        final aServicePoint = ServicePoint(name: 'a', abbreviation: '', locationCode: '', order: 16, kilometre: []);
        testAsync.run((_) {
          rxMockPunctuality.add(
            DelayModel.visible(
              delay: Delay(value: Duration.zero, location: ''),
            ),
          );
          testAsync.flushMicrotasks();
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 15)),
              data: [zeroSignal, tenSignal, aServicePoint, twentySignal],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(
          testee.modelValue,
          equals(JourneyPositionModel(currentPosition: tenSignal, nextServicePoint: aServicePoint)),
        );
        expect(emitRegister, hasLength(1));
      });

      test('currentPosition_whenSPWithOperationalArrivalTimeAndNoDelay_thenSetsToSPAfterOperationalTimeReached', () {
        // ARRANGE - passenger train: VPro speed and PüA reports are available
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 16,
          kilometre: [],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().add(Duration(seconds: 30)),
            ambiguousArrivalTime: now.now().add(Duration(seconds: 50)),
          ),
        );

        testAsync.run((_) {
          rxMockPunctuality.add(
            DelayModel.visible(
              delay: Delay(value: Duration.zero, location: ''),
            ),
          );
          testAsync.flushMicrotasks();
          rxMockJourney.add(
            Journey(
              metadata: Metadata(
                signaledPosition: SignaledPosition(order: 10),
                calculatedSpeeds: SplayTreeMap.of({16: const SingleSpeed(value: '80')}),
              ),
              data: [zeroSignal, tenSignal, aServicePoint, twentySignal],
            ),
          );
        });
        testAsync.flushMicrotasks();

        testAsync.elapse(Duration(seconds: 51));

        testAsync.flushMicrotasks();

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

      test('currentPosition_whenArrivalTimeOffTenSecondBoundary_thenDoesNotAdvanceEarly', () {
        // ARRANGE - guards against flooring the arrival time to whole ten seconds of the wall clock
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 16,
          kilometre: [],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().add(Duration(seconds: 47)),
            ambiguousArrivalTime: now.now().add(Duration(seconds: 33)),
          ),
        );

        testAsync.run((_) {
          rxMockPunctuality.add(
            DelayModel.visible(
              delay: Delay(value: Duration.zero, location: ''),
            ),
          );
          testAsync.flushMicrotasks();
          rxMockJourney.add(
            Journey(
              metadata: Metadata(
                signaledPosition: SignaledPosition(order: 10),
                calculatedSpeeds: SplayTreeMap.of({16: const SingleSpeed(value: '80')}),
              ),
              data: [zeroSignal, tenSignal, aServicePoint, twentySignal],
            ),
          );
        });
        testAsync.flushMicrotasks();

        testAsync.elapse(Duration(seconds: 31));
        testAsync.flushMicrotasks();
        expect(testee.modelValue.currentPosition, equals(tenSignal));

        testAsync.elapse(Duration(seconds: 3));
        testAsync.flushMicrotasks();
        expect(testee.modelValue.currentPosition, equals(aServicePoint));
      });

      test(
        'currentPosition_whenSPWithOperationalArrivalTimeAndPositiveDelay_thenReturnsSPAfterOperationalTimeMinusDelay',
        () {
          // ARRANGE - passenger train: VPro speed and PüA reports are available
          final now = DateTime(1970);
          final clock = Clock(() => now);

          final aServicePoint = ServicePoint(
            name: 'a',
            abbreviation: '',
            locationCode: '',
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
                DelayModel.visible(
                  delay: Delay(value: Duration(minutes: 1), location: ''),
                ),
              );
              testAsync.flushMicrotasks();
              rxMockJourney.add(
                Journey(
                  metadata: Metadata(
                    signaledPosition: SignaledPosition(order: 10),
                    calculatedSpeeds: SplayTreeMap.of({16: const SingleSpeed(value: '80')}),
                  ),
                  data: [zeroSignal, tenSignal, aServicePoint, twentySignal],
                ),
              );
            });
          });
          testAsync.flushMicrotasks();

          // delay is added to the operational arrival time, so nothing happens before 110s
          testAsync.elapse(Duration(seconds: 60));
          testAsync.flushMicrotasks();
          expect(testee.modelValue.currentPosition, equals(tenSignal));

          testAsync.elapse(Duration(seconds: 51));

          testAsync.flushMicrotasks();

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
        },
      );

      test('currentPosition_whenSPWithOperationalArrivalTimeAndNegativeDelay_thenCurrentPositionIsDirectlySP', () {
        // ARRANGE - passenger train: VPro speed and PüA reports are available
        final now = DateTime(1970);
        final clock = Clock(() => now);

        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
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
              DelayModel.visible(
                delay: Delay(value: Duration(minutes: -1), location: ''),
              ),
            );
            rxMockJourney.add(
              Journey(
                metadata: Metadata(
                  signaledPosition: SignaledPosition(order: 10),
                  calculatedSpeeds: SplayTreeMap.of({16: const SingleSpeed(value: '80')}),
                ),
                data: [zeroSignal, tenSignal, aServicePoint, twentySignal],
              ),
            );
          });
        });
        testAsync.flushMicrotasks();
        expect(
          emitRegister,
          orderedEquals([
            JourneyPositionModel(currentPosition: tenSignal, nextServicePoint: aServicePoint),
            JourneyPositionModel(
              currentPosition: aServicePoint,
              lastPosition: tenSignal,
              previousServicePoint: aServicePoint,
            ),
          ]),
        );
        expect(emitRegister, hasLength(2));
      });

      test('currentPosition_whenSPWithoutCalculatedSpeed_thenAdvancesByOperationalTimeWithoutDelay', () {
        // ARRANGE - cargo/empty material/short-term journey: operational forecast times exist, but never VPro or PüA.
        // A visible delay (e.g. left over from a diverted passenger train) must be ignored for such SPs.
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 16,
          kilometre: [],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().add(Duration(seconds: 30)),
            ambiguousArrivalTime: now.now().add(Duration(seconds: 50)),
          ),
        );

        testAsync.run((_) {
          rxMockPunctuality.add(
            DelayModel.visible(
              delay: Delay(value: Duration(minutes: 1), location: ''),
            ),
          );
          testAsync.flushMicrotasks();
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
              data: [zeroSignal, tenSignal, aServicePoint, twentySignal],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT & EXPECT - the operational arrival time is used, not the planned one
        testAsync.elapse(Duration(seconds: 35));
        testAsync.flushMicrotasks();
        expect(testee.modelValue.currentPosition, equals(tenSignal));

        // advanced by operational time without the delay applied
        testAsync.elapse(Duration(seconds: 16));
        testAsync.flushMicrotasks();
        expect(testee.modelValue.currentPosition, equals(aServicePoint));
        expect(emitRegister, hasLength(2));
      });

      test('currentPosition_whenSPWithoutCalculatedSpeedAndOnlyPlannedArrivalTime_thenAdvancesByPlannedTime', () {
        // ARRANGE - edge case: journey starting abroad or cargo/empty material started >4h early has only planned
        // times (no operational times, no VPro, no PüA) until the first CH signal is passed
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 16,
          kilometre: [],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().add(Duration(seconds: 30)),
          ),
        );

        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
              data: [zeroSignal, tenSignal, aServicePoint, twentySignal],
            ),
          );
        });
        testAsync.flushMicrotasks();
        expect(testee.modelValue.currentPosition, equals(tenSignal));

        // ACT
        testAsync.elapse(Duration(seconds: 31));
        testAsync.flushMicrotasks();

        // EXPECT - advanced by planned time as fallback
        expect(testee.modelValue.currentPosition, equals(aServicePoint));
        expect(emitRegister, hasLength(2));
      });

      test('currentPosition_whenSPWithCalculatedSpeedAndNoPunctuality_thenDoesNotAdvance', () {
        // ARRANGE - passenger train whose PüA has not (yet) been received: punctuality stays hidden although the SP
        // has a calculated (VPro) speed, so the advancement waits for the next signal
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 16,
          kilometre: [],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().add(Duration(seconds: 30)),
            ambiguousArrivalTime: now.now().add(Duration(seconds: 50)),
          ),
        );

        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(
                signaledPosition: SignaledPosition(order: 10),
                calculatedSpeeds: SplayTreeMap.of({16: const SingleSpeed(value: '80')}),
              ),
              data: [zeroSignal, tenSignal, aServicePoint, twentySignal],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT
        testAsync.elapse(Duration(seconds: 120));
        testAsync.flushMicrotasks();

        // EXPECT - no advancement without visible punctuality
        expect(testee.modelValue.currentPosition, equals(tenSignal));
        expect(emitRegister, hasLength(1));
      });

      test('currentPosition_whenSPWithCalculatedSpeedAndStalePunctuality_thenDoesNotAdvance', () {
        // ARRANGE - passenger train whose PüA reports stopped coming in: with a VPro speed the advancement waits for
        // the next signal instead of using the outdated delay
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 16,
          kilometre: [],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().add(Duration(seconds: 30)),
            ambiguousArrivalTime: now.now().add(Duration(seconds: 50)),
          ),
        );

        testAsync.run((_) {
          rxMockPunctuality.add(
            DelayModel.stale(
              delay: Delay(value: Duration(minutes: 1), location: ''),
            ),
          );
          testAsync.flushMicrotasks();
          rxMockJourney.add(
            Journey(
              metadata: Metadata(
                signaledPosition: SignaledPosition(order: 10),
                calculatedSpeeds: SplayTreeMap.of({16: const SingleSpeed(value: '80')}),
              ),
              data: [zeroSignal, tenSignal, aServicePoint, twentySignal],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT
        testAsync.elapse(Duration(seconds: 120));
        testAsync.flushMicrotasks();

        // EXPECT - no advancement with stale punctuality
        expect(testee.modelValue.currentPosition, equals(tenSignal));
        expect(emitRegister, hasLength(1));
      });

      test('currentPosition_whenDivertedPassengerTrain_thenAppliesDelayOnlyOnSPsWithCalculatedSpeed', () {
        // ARRANGE - diverted passenger train: the diverted section behaves like cargo (SP a without VPro/PüA),
        // the rest like a passenger train (SP b with VPro and PüA)
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 16,
          kilometre: [],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().add(Duration(seconds: 30)),
            ambiguousArrivalTime: now.now().add(Duration(seconds: 50)),
          ),
        );
        final bServicePoint = ServicePoint(
          name: 'b',
          abbreviation: '',
          locationCode: '',
          order: 26,
          kilometre: [],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().add(Duration(seconds: 90)),
            ambiguousArrivalTime: now.now().add(Duration(seconds: 110)),
          ),
        );
        const thirtySignal = Signal(order: 30, kilometre: []);
        final journeyData = [zeroSignal, tenSignal, aServicePoint, twentySignal, bServicePoint, thirtySignal];
        final calculatedSpeeds = SplayTreeMap<int, SingleSpeed?>.of({26: const SingleSpeed(value: '80')});

        testAsync.run((_) {
          rxMockPunctuality.add(
            DelayModel.visible(
              delay: Delay(value: Duration(minutes: 1), location: ''),
            ),
          );
          testAsync.flushMicrotasks();
          rxMockJourney.add(
            Journey(
              metadata: Metadata(
                signaledPosition: SignaledPosition(order: 10),
                calculatedSpeeds: calculatedSpeeds,
              ),
              data: journeyData,
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT & EXPECT - SP a is reached by operational time, the delay is ignored on the diverted section
        testAsync.elapse(Duration(seconds: 51));
        testAsync.flushMicrotasks();
        expect(testee.modelValue.currentPosition, equals(aServicePoint));

        // the signal after SP a is passed, back on the regular route
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(
                signaledPosition: SignaledPosition(order: 20),
                calculatedSpeeds: calculatedSpeeds,
              ),
              data: journeyData,
            ),
          );
        });
        testAsync.flushMicrotasks();
        expect(testee.modelValue.currentPosition, equals(twentySignal));

        // the delay is applied again for SP b, so it is not reached by operational time alone
        testAsync.elapse(Duration(seconds: 100));
        testAsync.flushMicrotasks();
        expect(testee.modelValue.currentPosition, equals(twentySignal));

        testAsync.elapse(Duration(seconds: 120));
        testAsync.flushMicrotasks();
        expect(testee.modelValue.currentPosition, equals(bServicePoint));
        expect(emitRegister, hasLength(4));
      });

      test('currentPosition_whenSignalBetweenPositionAndNextSP_thenDoesNotAdvance', () {
        // ARRANGE - a signal before the next service point cancels the time-based advancement
        const fifteenSignal = Signal(order: 15, kilometre: []);
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 16,
          kilometre: [],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().add(Duration(seconds: 30)),
            ambiguousArrivalTime: now.now().add(Duration(seconds: 50)),
          ),
        );

        testAsync.run((_) {
          rxMockPunctuality.add(
            DelayModel.visible(
              delay: Delay(value: Duration.zero, location: ''),
            ),
          );
          testAsync.flushMicrotasks();
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
              data: [zeroSignal, tenSignal, fifteenSignal, aServicePoint, twentySignal],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT
        testAsync.elapse(Duration(seconds: 120));
        testAsync.flushMicrotasks();

        // EXPECT - still on the point before the signal
        expect(testee.modelValue.currentPosition, equals(tenSignal));
        expect(emitRegister, hasLength(1));
      });

      test('currentPosition_whenOnServicePoint_thenDoesNotAdvanceToNextSPByTime', () {
        // ARRANGE - time-based advancement only starts from the last signal before a service point
        final aServicePoint = ServicePoint(name: 'a', abbreviation: '', locationCode: '', order: 10, kilometre: []);
        final bServicePoint = ServicePoint(
          name: 'b',
          abbreviation: '',
          locationCode: '',
          order: 16,
          kilometre: [],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().add(Duration(seconds: 30)),
            ambiguousArrivalTime: now.now().add(Duration(seconds: 50)),
          ),
        );

        testAsync.run((_) {
          rxMockPunctuality.add(
            DelayModel.visible(
              delay: Delay(value: Duration.zero, location: ''),
            ),
          );
          testAsync.flushMicrotasks();
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
              data: [zeroSignal, aServicePoint, bServicePoint, twentySignal],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT
        testAsync.elapse(Duration(seconds: 120));
        testAsync.flushMicrotasks();

        // EXPECT
        expect(testee.modelValue.currentPosition, equals(aServicePoint));
        expect(emitRegister, hasLength(1));
      });
    });

    group('signaled position priority', () {
      test('currentPosition_whenNewSignaledPositionBehindTimedAdvancement_thenSignalWins', () {
        const fifteenSignal = Signal(order: 15, kilometre: []);
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 16,
          kilometre: [],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().subtract(Duration(seconds: 30)),
            ambiguousArrivalTime: now.now().subtract(Duration(seconds: 5)),
          ),
        );
        final journeyData = [zeroSignal, tenSignal, fifteenSignal, aServicePoint, twentySignal];

        // ARRANGE
        testAsync.run((_) {
          rxMockPunctuality.add(
            DelayModel.visible(
              delay: Delay(value: Duration.zero, location: ''),
            ),
          );
          rxMockJourney.add(
            Journey(
              metadata: Metadata(
                signaledPosition: SignaledPosition(order: 15),
                calculatedSpeeds: SplayTreeMap.of({16: const SingleSpeed(value: '80')}),
              ),
              data: journeyData,
            ),
          );
        });
        testAsync.flushMicrotasks();
        expect(testee.modelValue.currentPosition, equals(aServicePoint));

        // ACT
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(
                signaledPosition: SignaledPosition(order: 12),
                calculatedSpeeds: SplayTreeMap.of({16: const SingleSpeed(value: '80')}),
              ),
              data: journeyData,
            ),
          );
        });
        testAsync.flushMicrotasks();

        // EXPECT
        expect(testee.modelValue.currentPosition, equals(tenSignal));
        expect(testee.modelValue.lastPosition, equals(aServicePoint));
      });

      test('currentPosition_whenNewSignaledPositionBehindManualPosition_thenSignalWins', () {
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 25,
          kilometre: [],
          isStop: true,
        );
        final journeyData = [zeroSignal, tenSignal, twentySignal, aServicePoint];

        // ARRANGE
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 0)),
              data: journeyData,
            ),
          );
          testAsync.flushMicrotasks();
          journeySettingsViewModel.updateJourneyAdvancement(Manual());
          testee.setManualPosition(aServicePoint);
          testAsync.flushMicrotasks();
        });
        expect(testee.modelValue.currentPosition, equals(aServicePoint));
        expect(testee.modelValue.isManualPosition, isTrue);

        // ACT
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
              data: journeyData,
            ),
          );
        });
        testAsync.flushMicrotasks();

        // EXPECT
        expect(testee.modelValue.currentPosition, equals(tenSignal));
        expect(testee.modelValue.isManualPosition, isFalse);
      });

      test('currentPosition_whenJourneyUpdateWithUnchangedSignaledPosition_thenKeepsManualPosition', () {
        // ARRANGE
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 25,
          kilometre: [],
          isStop: true,
        );
        final journeyData = [zeroSignal, tenSignal, twentySignal, aServicePoint];
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
              data: journeyData,
            ),
          );
          testAsync.flushMicrotasks();
          journeySettingsViewModel.updateJourneyAdvancement(Manual());
          testee.setManualPosition(aServicePoint);
          testAsync.flushMicrotasks();
        });
        expect(testee.modelValue.currentPosition, equals(aServicePoint));

        // ACT
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
              data: journeyData,
            ),
          );
        });
        testAsync.flushMicrotasks();

        // EXPECT
        expect(testee.modelValue.currentPosition, equals(aServicePoint));
        expect(testee.modelValue.isManualPosition, isTrue);
      });
    });

    group('lastPosition calculation', () {
      test('lastPosition_whenJourneyUpdatedWithSameCurrentPosition_thenReturnsLastPosition', () {
        // ARRANGE
        final aJourney = Journey(
          metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
          data: [tenSignal],
        );
        testAsync.run((_) {
          rxMockJourney.add(aJourney);
          testAsync.flushMicrotasks();
          rxMockJourney.add(aJourney);
          testAsync.flushMicrotasks();
        });

        // ACT & EXPECT
        expect(testee.modelValue, equals(JourneyPositionModel(currentPosition: tenSignal, lastPosition: null)));
        expect(emitRegister, hasLength(1));
        expect(
          emitRegister,
          orderedEquals([
            JourneyPositionModel(currentPosition: tenSignal, lastPosition: null),
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
          testAsync.flushMicrotasks();
          rxMockJourney.add(bJourney);
          testAsync.flushMicrotasks();
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
            testAsync.flushMicrotasks();
            rxMockJourney.add(bJourney);
            testAsync.flushMicrotasks();
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
    });

    group('previous and next service point', () {
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
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue.previousServicePoint, isNull);
      });

      test('previousServicePoint_whenNoServicePointBeforeCurrentPosition_isNull', () {
        // ARRANGE
        final aServicePoint = ServicePoint(name: 'a', abbreviation: '', locationCode: '', order: 10, kilometre: []);
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 0)),
              data: [zeroSignal, aServicePoint],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue.previousServicePoint, isNull);
      });

      test('previousServicePoint_whenCurrentPositionIsServicePoint_thenIsThisServicePoint', () {
        // ARRANGE
        final aServicePoint = ServicePoint(name: 'a', abbreviation: '', locationCode: '', order: 10, kilometre: []);
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
              data: [zeroSignal, aServicePoint],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue.previousServicePoint, equals(aServicePoint));
      });

      test('previousServicePoint_whenCurrentPositionIsAfterServicePoint_thenIsThisServicePoint', () {
        // ARRANGE
        final aServicePoint = ServicePoint(name: 'a', abbreviation: '', locationCode: '', order: 10, kilometre: []);
        final bServicePoint = ServicePoint(name: 'b', abbreviation: '', locationCode: '', order: 15, kilometre: []);
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
              data: [zeroSignal, aServicePoint, bServicePoint, twentySignal],
            ),
          );
        });
        testAsync.flushMicrotasks();

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
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue.nextServicePoint, isNull);
      });

      test('nextServicePoint_whenIsOnServicePointAndNoOther_thenIsNull', () {
        // ARRANGE
        final aServicePoint = ServicePoint(name: 'a', abbreviation: '', locationCode: '', order: 20, kilometre: []);
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
              data: [zeroSignal, tenSignal, aServicePoint],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue.nextServicePoint, isNull);
      });

      test('nextServicePoint_whenIsOnServicePointAndHasOther_thenIsOther', () {
        // ARRANGE
        final aServicePoint = ServicePoint(name: 'a', abbreviation: '', locationCode: '', order: 20, kilometre: []);
        final bServicePoint = ServicePoint(name: 'b', abbreviation: '', locationCode: '', order: 25, kilometre: []);
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
              data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue.nextServicePoint, equals(bServicePoint));
      });
    });

    group('previous and next stop', () {
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
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue.previousStop, isNull);
      });

      test('previousStop_whenIsOnServicePointThatIsNoStop_thenIsNull', () {
        // ARRANGE
        final aServicePoint = ServicePoint(name: 'a', abbreviation: '', locationCode: '', order: 20, kilometre: []);
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
              data: [zeroSignal, tenSignal, aServicePoint],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue.previousStop, isNull);
      });

      test('previousStop_whenIsOnServicePointThatIsStopAndNoOther_thenIsThisServicePoint', () {
        // ARRANGE
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 20,
          kilometre: [],
          isStop: true,
        );
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
              data: [zeroSignal, tenSignal, aServicePoint],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue.previousStop, equals(aServicePoint));
      });

      test('previousStop_whenIsOnServicePointAndFutureOtherThatIsStop_thenIsCurrentOne', () {
        // ARRANGE
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 20,
          kilometre: [],
          isStop: true,
        );
        final bServicePoint = ServicePoint(
          name: 'b',
          abbreviation: '',
          locationCode: '',
          order: 25,
          kilometre: [],
          isStop: true,
        );
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
              data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue.previousStop, equals(aServicePoint));
      });

      test('previousStop_whenIsOnServicePointAndHasPastOtherThatIsStop_thenIsCurrentOne', () {
        // ARRANGE
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 20,
          kilometre: [],
          isStop: true,
        );
        final bServicePoint = ServicePoint(
          name: 'b',
          abbreviation: '',
          locationCode: '',
          order: 25,
          kilometre: [],
          isStop: true,
        );
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 25)),
              data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
            ),
          );
        });
        testAsync.flushMicrotasks();

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
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue.nextStop, isNull);
      });

      test('nextStop_whenIsOnServicePointAndNoOther_thenIsNull', () {
        // ARRANGE
        final aServicePoint = ServicePoint(name: 'a', abbreviation: '', locationCode: '', order: 20, kilometre: []);
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
              data: [zeroSignal, tenSignal, aServicePoint],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue.nextStop, isNull);
      });

      test('nextStop_whenIsOnServicePointAndHasOtherThatIsNoStop_thenIsNull', () {
        // ARRANGE
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 20,
          kilometre: [],
          isStop: true,
        );
        final bServicePoint = ServicePoint(name: 'b', abbreviation: '', locationCode: '', order: 25, kilometre: []);
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
              data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
            ),
          );
          testAsync.flushMicrotasks();
        });

        // ACT & EXPECT
        expect(testee.modelValue.nextStop, isNull);
      });

      test('nextStop_whenIsOnServicePointAndHasOtherThatIsStop_thenIsOther', () {
        // ARRANGE
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 20,
          kilometre: [],
          isStop: true,
        );
        final bServicePoint = ServicePoint(
          name: 'b',
          abbreviation: '',
          locationCode: '',
          order: 25,
          kilometre: [],
          isStop: true,
        );
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 20)),
              data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // ACT & EXPECT
        expect(testee.modelValue.nextStop, equals(bServicePoint));
      });
    });

    group('manual position', () {
      test('setManualPosition_whenHasNoSignaledPosition_thenMovesCurrentAndLastPosition', () {
        // ARRANGE
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 20,
          kilometre: [],
          isStop: true,
        );
        final bServicePoint = ServicePoint(
          name: 'b',
          abbreviation: '',
          locationCode: '',
          order: 25,
          kilometre: [],
          isStop: true,
        );
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(),
              data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
            ),
          );
        });
        testAsync.flushMicrotasks();
        expect(testee.modelValue.currentPosition, equals(zeroSignal));
        expect(testee.modelValue.isManualPosition, isFalse);

        // ACT
        testAsync.run((async) {
          journeySettingsViewModel.updateJourneyAdvancement(Manual());
          testee.setManualPosition(aServicePoint);
          async.flushMicrotasks();
        });

        // EXPECT
        expect(testee.modelValue.currentPosition, equals(aServicePoint));
        expect(testee.modelValue.lastPosition, equals(zeroSignal));
        expect(testee.modelValue.isManualPosition, isTrue);
      });

      test('setManualPosition_whenHasSignaledPosition_thenMovesToNewPosition', () {
        // ARRANGE
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 20,
          kilometre: [],
          isStop: true,
        );
        final bServicePoint = ServicePoint(
          name: 'b',
          abbreviation: '',
          locationCode: '',
          order: 25,
          kilometre: [],
          isStop: true,
        );
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 25)),
              data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
            ),
          );
        });
        testAsync.flushMicrotasks();
        expect(testee.modelValue.currentPosition, equals(bServicePoint));
        expect(testee.modelValue.isManualPosition, isFalse);

        // ACT
        testAsync.run((async) {
          journeySettingsViewModel.updateJourneyAdvancement(Manual());
          testee.setManualPosition(aServicePoint);
          async.flushMicrotasks();
        });

        // EXPECT
        expect(testee.modelValue.currentPosition, equals(aServicePoint));
        expect(testee.modelValue.lastPosition, equals(bServicePoint));
        expect(testee.modelValue.isManualPosition, isTrue);
      });

      test('setManualPosition_whenIsGivenNullPosition_thenMovesToSignaledPosition', () {
        // ARRANGE
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 20,
          kilometre: [],
          isStop: true,
        );
        final bServicePoint = ServicePoint(
          name: 'b',
          abbreviation: '',
          locationCode: '',
          order: 25,
          kilometre: [],
          isStop: true,
        );
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 25)),
              data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
            ),
          );
        });
        testAsync.flushMicrotasks();
        expect(testee.modelValue.currentPosition, equals(bServicePoint));
        expect(testee.modelValue.isManualPosition, isFalse);

        testAsync.run((async) {
          journeySettingsViewModel.updateJourneyAdvancement(Manual());
          testee.setManualPosition(aServicePoint);
          async.flushMicrotasks();
        });

        expect(testee.modelValue.currentPosition, equals(aServicePoint));
        expect(testee.modelValue.lastPosition, equals(bServicePoint));
        expect(testee.modelValue.isManualPosition, isTrue);

        // ACT
        testAsync.run((_) {
          testee.setManualPosition(null);
          testAsync.flushMicrotasks();
        });

        expect(testee.modelValue.currentPosition, equals(bServicePoint));
        expect(testee.modelValue.lastPosition, equals(aServicePoint));
        expect(testee.modelValue.isManualPosition, isFalse);
      });

      test('currentPosition_afterSetManualPositionThenJourneyUpdate_movesToJourneyUpdatePosition', () {
        // ARRANGE
        final aServicePoint = ServicePoint(
          name: 'a',
          abbreviation: '',
          locationCode: '',
          order: 20,
          kilometre: [],
          isStop: true,
        );
        final bServicePoint = ServicePoint(
          name: 'b',
          abbreviation: '',
          locationCode: '',
          order: 25,
          kilometre: [],
          isStop: true,
        );
        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 10)),
              data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
            ),
          );
          testAsync.flushMicrotasks();
          journeySettingsViewModel.updateJourneyAdvancement(Manual());
          testee.setManualPosition(aServicePoint);
        });
        testAsync.flushMicrotasks();
        expect(testee.modelValue.currentPosition, equals(aServicePoint));
        expect(testee.modelValue.isManualPosition, isTrue);

        // ACT
        testAsync.run((_) {
          journeySettingsViewModel.updateJourneyAdvancement(Automatic());
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 25)),
              data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // EXPECT
        expect(testee.modelValue.currentPosition, equals(bServicePoint));
        expect(testee.modelValue.isManualPosition, isFalse);
      });
    });

    group('setManualPosition timer advancement', () {
      test(
        'setManualPosition_whenSPHasArrivalTimeAndNextSPHasArrivalTime_thenAutoAdvancesToNextSPAfterTimer',
        () {
          // ARRANGE
          // clock is at DateTime(1970) == T=0
          // arrivalTime of A = T - 10s, so timeSinceArrival = 10s
          // nextArrivalTime of B = T + 30s
          // => nextServicePointDuration = (T+30s + 10s) - T = 40s
          final aServicePoint = ServicePoint(
            name: 'a',
            abbreviation: '',
            locationCode: '',
            order: 20,
            kilometre: [],
            isStop: true,
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: now.now().subtract(Duration(seconds: 10)),
            ),
          );
          final bServicePoint = ServicePoint(
            name: 'b',
            abbreviation: '',
            locationCode: '',
            order: 25,
            kilometre: [],
            isStop: true,
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: now.now().add(Duration(seconds: 30)),
            ),
          );

          testAsync.run((_) {
            rxMockJourney.add(
              Journey(
                metadata: Metadata(),
                data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
              ),
            );
            testAsync.flushMicrotasks();
            journeySettingsViewModel.updateJourneyAdvancement(Manual());
            testee.setManualPosition(aServicePoint);
            testAsync.flushMicrotasks();
          });
          expect(testee.modelValue.currentPosition, equals(aServicePoint));
          expect(testee.modelValue.isManualPosition, isTrue);
          emitRegister.clear();

          // ACT – elapse past the 40 s timer
          testAsync.elapse(Duration(seconds: 41));
          testAsync.flushMicrotasks();

          // EXPECT
          expect(testee.modelValue.currentPosition, equals(bServicePoint));
          expect(testee.modelValue.isManualPosition, isTrue);
          expect(emitRegister, hasLength(1));
          expect((emitRegister.single as JourneyPositionModel).isManualPosition, isTrue);
        },
      );

      test(
        'setManualPosition_whenSPHasNoArrivalTime_thenDoesNotAutoAdvance',
        () {
          // ARRANGE – A has no arrival time → no timer is set
          final aServicePoint = ServicePoint(
            name: 'a',
            abbreviation: '',
            locationCode: '',
            order: 20,
            kilometre: [],
            isStop: true,
          );
          final bServicePoint = ServicePoint(
            name: 'b',
            abbreviation: '',
            locationCode: '',
            order: 25,
            kilometre: [],
            isStop: true,
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: now.now().add(Duration(seconds: 30)),
            ),
          );

          testAsync.run((_) {
            rxMockJourney.add(
              Journey(
                metadata: Metadata(),
                data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
              ),
            );
            testAsync.flushMicrotasks();
            journeySettingsViewModel.updateJourneyAdvancement(Manual());
            testee.setManualPosition(aServicePoint);
            testAsync.flushMicrotasks();
          });
          emitRegister.clear();

          // ACT
          testAsync.elapse(Duration(seconds: 100));
          testAsync.flushMicrotasks();

          // EXPECT – still on A
          expect(testee.modelValue.currentPosition, equals(aServicePoint));
          expect(testee.modelValue.isManualPosition, isTrue);
          expect(emitRegister, hasLength(0));
        },
      );

      test(
        'setManualPosition_whenCalledAgainBeforeTimerExpires_thenOldTimerIsCancelledAndPositionDoesNotChange',
        () {
          // ARRANGE
          // A → B timer would fire after 40 s
          // After setting B as position, A→B timer is cancelled; B has no C arrival time so no new timer
          final aServicePoint = ServicePoint(
            name: 'a',
            abbreviation: '',
            locationCode: '',
            order: 20,
            kilometre: [],
            isStop: true,
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: now.now().subtract(Duration(seconds: 10)),
            ),
          );
          final bServicePoint = ServicePoint(
            name: 'b',
            abbreviation: '',
            locationCode: '',
            order: 25,
            kilometre: [],
            isStop: true,
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: now.now().add(Duration(seconds: 30)),
            ),
          );
          final cServicePoint = ServicePoint(
            name: 'c',
            abbreviation: '',
            locationCode: '',
            order: 30,
            kilometre: [],
            isStop: true,
          );

          testAsync.run((_) {
            rxMockJourney.add(
              Journey(
                metadata: Metadata(),
                data: [zeroSignal, aServicePoint, bServicePoint, cServicePoint],
              ),
            );
            testAsync.flushMicrotasks();
            journeySettingsViewModel.updateJourneyAdvancement(Manual());
            testee.setManualPosition(aServicePoint); // starts A→B timer (40 s)
            testAsync.flushMicrotasks();
          });

          // Override with B before the timer fires → cancels A→B timer
          testAsync.run((_) {
            testee.setManualPosition(bServicePoint);
            testAsync.flushMicrotasks();
          });
          expect(testee.modelValue.currentPosition, equals(bServicePoint));
          expect(testee.modelValue.isManualPosition, isTrue);
          emitRegister.clear();

          // ACT – advance past where A→B timer would have fired
          testAsync.elapse(Duration(seconds: 50));
          testAsync.flushMicrotasks();

          // EXPECT – position remains B (old timer did not fire)
          expect(testee.modelValue.currentPosition, equals(bServicePoint));
          expect(testee.modelValue.isManualPosition, isTrue);
          expect(emitRegister, hasLength(0));
        },
      );

      test(
        'setManualPosition_whenTimerFiresButModeIsNoLongerManual_thenDoesNotAutoAdvance',
        () {
          // ARRANGE
          final aServicePoint = ServicePoint(
            name: 'a',
            abbreviation: '',
            locationCode: '',
            order: 20,
            kilometre: [],
            isStop: true,
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: now.now().subtract(Duration(seconds: 10)),
            ),
          );
          final bServicePoint = ServicePoint(
            name: 'b',
            abbreviation: '',
            locationCode: '',
            order: 25,
            kilometre: [],
            isStop: true,
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: now.now().add(Duration(seconds: 30)),
            ),
          );

          testAsync.run((_) {
            rxMockJourney.add(
              Journey(
                metadata: Metadata(signaledPosition: SignaledPosition(order: 0)),
                data: [zeroSignal, tenSignal, aServicePoint, bServicePoint],
              ),
            );
            testAsync.flushMicrotasks();
            journeySettingsViewModel.updateJourneyAdvancement(Manual());
            testee.setManualPosition(aServicePoint); // starts A→B timer (40 s)
            testAsync.flushMicrotasks();
          });
          expect(testee.modelValue.currentPosition, equals(aServicePoint));
          expect(testee.modelValue.isManualPosition, isTrue);

          // Switch back to Automatic before timer fires
          testAsync.run((_) {
            journeySettingsViewModel.updateJourneyAdvancement(Automatic());
            testAsync.flushMicrotasks();
          });
          emitRegister.clear();

          // ACT – let the timer fire
          testAsync.elapse(Duration(seconds: 41));
          testAsync.flushMicrotasks();

          // EXPECT – guard `isInManualCycle` prevented the advancement
          expect(testee.modelValue.currentPosition, isNot(equals(bServicePoint)));
          expect(testee.modelValue.isManualPosition, isTrue);
          expect(emitRegister, hasLength(0));
        },
      );

      test(
        'setManualPosition_whenTimerAdvances_thenContinuesAdvancingWithSameTimeDifference',
        () {
          // ARRANGE
          // arrivalTime of A = T - 10s, so timeSinceArrival = 10s
          // arrivalTime of B = T + 30s => advancement to B after 40s
          // arrivalTime of C = T + 60s => advancement to C 30s after B (time difference of 10s is kept)
          final aServicePoint = ServicePoint(
            name: 'a',
            abbreviation: '',
            locationCode: '',
            order: 20,
            kilometre: [],
            isStop: true,
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: now.now().subtract(Duration(seconds: 10)),
            ),
          );
          final bServicePoint = ServicePoint(
            name: 'b',
            abbreviation: '',
            locationCode: '',
            order: 25,
            kilometre: [],
            isStop: true,
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: now.now().add(Duration(seconds: 30)),
            ),
          );
          final cServicePoint = ServicePoint(
            name: 'c',
            abbreviation: '',
            locationCode: '',
            order: 30,
            kilometre: [],
            isStop: true,
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedArrivalTime: now.now().add(Duration(seconds: 60)),
            ),
          );

          testAsync.run((_) {
            rxMockJourney.add(
              Journey(
                metadata: Metadata(),
                data: [zeroSignal, aServicePoint, bServicePoint, cServicePoint],
              ),
            );
            testAsync.flushMicrotasks();
            journeySettingsViewModel.updateJourneyAdvancement(Manual());
            testee.setManualPosition(aServicePoint);
            testAsync.flushMicrotasks();
          });
          expect(testee.modelValue.currentPosition, equals(aServicePoint));

          // ACT & EXPECT – advances to B after 40s
          testAsync.elapse(Duration(seconds: 41));
          testAsync.flushMicrotasks();
          expect(testee.modelValue.currentPosition, equals(bServicePoint));

          // still on B before C is due
          testAsync.elapse(Duration(seconds: 20));
          testAsync.flushMicrotasks();
          expect(testee.modelValue.currentPosition, equals(bServicePoint));

          // advances to C with the preserved time difference
          testAsync.elapse(Duration(seconds: 10));
          testAsync.flushMicrotasks();
          expect(testee.modelValue.currentPosition, equals(cServicePoint));
          expect(testee.modelValue.isManualPosition, isTrue);
        },
      );
    });

    group('timed route advancement (Iselle -> Domodossola)', () {
      test('handleTimedRoute_whenInTimedRouteWithPlannedArrivalTime_thenAdvancesToNextServicePointAfterTimer', () {
        // ARRANGE - Set up timed route: Iselle (CH01952) -> Varzo (CH01951)
        final point1 = ServicePoint(
          name: 'Iselle',
          abbreviation: 'ISL',
          locationCode: 'CH01952',
          order: 11,
          kilometre: [0.0],
        );
        final point2 = ServicePoint(
          name: 'Varzo',
          abbreviation: 'VRZ',
          locationCode: 'CH01951',
          order: 15,
          kilometre: [5.0],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().add(Duration(seconds: 40)),
          ),
        );
        final point3 = ServicePoint(
          name: 'Preglia',
          abbreviation: 'PRG',
          locationCode: 'CH01950',
          order: 20,
          kilometre: [10.0],
        );

        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 11)),
              data: [tenSignal, point1, point2, point3],
            ),
          );
        });
        testAsync.flushMicrotasks();

        expect(testee.modelValue.currentPosition, equals(point1));
        expect(testee.modelValue.isManualPosition, isFalse);
        expect(emitRegister, hasLength(1));
        emitRegister.clear();

        // ACT - Elapse time until service point should be reached
        testAsync.elapse(Duration(seconds: 41));
        testAsync.flushMicrotasks();

        // EXPECT - Position should now be at the next timed service point
        expect(
          testee.modelValue.currentPosition,
          equals(point2),
        );
        expect(testee.modelValue.isManualPosition, isFalse);
        expect(
          emitRegister,
          orderedEquals([
            JourneyPositionModel(
              currentPosition: point2,
              previousServicePoint: point2,
              nextServicePoint: point3,
              lastPosition: point1,
            ),
          ]),
        );
      });

      test('handleTimedRoute_whenInSecondTimedRoute_thenAdvancesToCorrectServicePoint', () {
        // ARRANGE - Set up second timed route: Pino Confine (CH15419) -> PINT (CH05862)
        final point1 = ServicePoint(
          name: 'Pino Confine',
          abbreviation: 'PIN',
          locationCode: 'CH15419',
          order: 11,
          kilometre: [0.0],
        );
        final point2 = ServicePoint(
          name: 'PINT',
          abbreviation: 'PNT',
          locationCode: 'CH05862',
          order: 15,
          kilometre: [5.0],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().add(Duration(seconds: 35)),
          ),
        );

        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 11)),
              data: [tenSignal, point1, point2],
            ),
          );
        });
        testAsync.flushMicrotasks();

        expect(testee.modelValue.currentPosition, equals(point1));
        expect(testee.modelValue.isManualPosition, isFalse);
        emitRegister.clear();

        // ACT - Elapse time until service point should be reached
        testAsync.elapse(Duration(seconds: 36));
        testAsync.flushMicrotasks();

        // EXPECT - Position should advance to second timed service point
        expect(
          testee.modelValue.currentPosition,
          equals(point2),
        );
        expect(testee.modelValue.isManualPosition, isFalse);
      });

      test('handleTimedRoute_whenTimedPointReachedWithNegativeTime_thenAdvancesImmediately', () {
        // ARRANGE - Create a timed route where the service point should already be reached
        final point1 = ServicePoint(
          name: 'Iselle',
          abbreviation: 'ISL',
          locationCode: 'CH01952',
          order: 11,
          kilometre: [0.0],
        );
        final point2 = ServicePoint(
          name: 'Varzo',
          abbreviation: 'VRZ',
          locationCode: 'CH01951',
          order: 15,
          kilometre: [5.0],
          arrivalDepartureTime: ArrivalDepartureTime(
            plannedArrivalTime: now.now().subtract(Duration(seconds: 5)),
          ),
        );

        testAsync.run((_) {
          rxMockJourney.add(
            Journey(
              metadata: Metadata(signaledPosition: SignaledPosition(order: 11)),
              data: [tenSignal, point1, point2],
            ),
          );
        });
        testAsync.flushMicrotasks();

        // EXPECT - Position is set to service point immediately
        expect(
          testee.modelValue.currentPosition,
          equals(point2),
        );
        expect(testee.modelValue.isManualPosition, isFalse);
        expect(emitRegister, hasLength(2));
      });
    });
  });
}

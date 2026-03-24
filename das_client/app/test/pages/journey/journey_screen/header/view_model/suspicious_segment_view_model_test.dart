import 'dart:async';

import 'package:app/pages/journey/journey_screen/header/view_model/model/suspicious_segment_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/suspicious_segment_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../../test_util.dart';
import 'suspicious_segment_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyPositionViewModel>(),
  MockSpec<JourneyViewModel>(),
  MockSpec<NotificationPriorityQueueViewModel>(),
])
void main() {
  late BehaviorSubject<Journey?> rxMockJourney;
  late BehaviorSubject<JourneyPositionModel> rxMockJourneyPosition;
  late SuspiciousSegmentViewModel testee;
  late FakeAsync testAsync;
  final List<dynamic> emitRegister = [];
  late StreamSubscription<SuspiciousSegmentModel> modelSubscription;
  late MockJourneyViewModel mockJourneyViewModel;
  late MockJourneyPositionViewModel mockJourneyPositionViewModel;
  late MockNotificationPriorityQueueViewModel mockNotificationViewModel;

  setUp(() {
    fakeAsync((fakeAsync) {
      testAsync = fakeAsync;
      rxMockJourney = BehaviorSubject<Journey?>.seeded(null);
      rxMockJourneyPosition = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
      mockJourneyViewModel = MockJourneyViewModel();
      mockJourneyPositionViewModel = MockJourneyPositionViewModel();
      mockNotificationViewModel = MockNotificationPriorityQueueViewModel();
      when(mockJourneyViewModel.journey).thenAnswer((_) => rxMockJourney.stream);
      when(mockJourneyPositionViewModel.model).thenAnswer((_) => rxMockJourneyPosition.stream);
      testee = SuspiciousSegmentViewModel(
        journeyPositionViewModel: mockJourneyPositionViewModel,
        journeyViewModel: mockJourneyViewModel,
        notificationVM: mockNotificationViewModel,
      );
      modelSubscription = testee.model.listen(emitRegister.add);
      processStreams(fakeAsync: fakeAsync);
    });
  });

  tearDown(() {
    modelSubscription.cancel();
    emitRegister.clear();
    reset(mockNotificationViewModel);
    testee.dispose();
    rxMockJourneyPosition.close();
    rxMockJourney.close();
  });

  // Journey points used across tests
  final signalA = Signal(order: 50, kilometre: []);
  final stopA = ServicePoint(name: 'Stop A', abbreviation: 'SA', locationCode: '', order: 100, kilometre: []);
  final stopB = ServicePoint(name: 'Stop B', abbreviation: 'SB', locationCode: '', order: 500, kilometre: []);
  final stopC = ServicePoint(name: 'Stop C', abbreviation: 'SC', locationCode: '', order: 1000, kilometre: []);
  final stopD = ServicePoint(name: 'Stop D', abbreviation: 'SD', locationCode: '', order: 1500, kilometre: []);

  // Suspicious segment covering stopA..stopB
  final suspiciousSegmentAB = SuspiciousSegment(startOrder: stopA.order, endOrder: stopB.order);
  // Suspicious segment covering stopC..stopD
  final suspiciousSegmentCD = SuspiciousSegment(startOrder: stopC.order, endOrder: stopD.order);

  // ---------------------------------------------------------------------------
  // Initial state
  // ---------------------------------------------------------------------------

  test('modelValue_whenNoJourney_thenIsHidden', () {
    expect(testee.modelValue, equals(SuspiciousSegmentHidden()));
  });

  test('modelValue_whenJourneyHasNoSuspiciousSegments_thenIsHidden', () {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(journeyStart: signalA),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentHidden()));
    verifyNever(mockNotificationViewModel.insert(type: anyNamed('type')));
    verifyNever(mockNotificationViewModel.remove(type: anyNamed('type')));
  });

  test('modelValue_whenJourneyOpenedWithSuspiciousSegment_thenIsVisible', () {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentVisible()));
    expect(emitRegister, hasLength(2));
    expect(emitRegister.last, equals(SuspiciousSegmentVisible()));
    verify(mockNotificationViewModel.insert(type: .suspiciousSegment)).called(1);
    verifyNever(mockNotificationViewModel.remove(type: .suspiciousSegment));
  });

  test('modelValue_whenJourneyOpenedWithSuspiciousSegmentAndPositionAtStart_thenIsVisible', () {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: signalA));
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentVisible()));
  });

  test('modelValue_whenPositionAfterSuspiciousSegmentEnd_thenIsHidden', () {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      // Position advances past the suspicious segment end (stopB, order 500)
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: stopC));
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentHidden()));
    expect(emitRegister.last, equals(SuspiciousSegmentHidden()));
    verify(mockNotificationViewModel.remove(type: .suspiciousSegment)).called(greaterThanOrEqualTo(1));
  });

  test('modelValue_whenPositionWithinSuspiciousSegment_thenStaysVisible', () {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: stopA));
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentVisible()));
  });

  test('modelValue_whenPositionAtSuspiciousSegmentEnd_thenStaysVisible', () {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      // Exactly at the end order of the suspicious segment – not yet passed
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: stopB));
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentVisible()));
  });

  test('modelValue_whenMultipleSuspiciousSegmentsAndPositionAfterLast_thenIsHidden', () {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB, suspiciousSegmentCD],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      // beyond all segments
      final beyondD = Signal(order: 2000, kilometre: []);
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: beyondD));
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentHidden()));
  });

  test('modelValue_whenMultipleSuspiciousSegmentsAndPositionBetweenThem_thenStaysVisible', () {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB, suspiciousSegmentCD],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      // Between the two segments – first passed but second not yet
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: stopC));
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentVisible()));
  });

  test('modelValue_whenTmsVadUpdateRemovesSuspiciousSegment_thenIsHidden', () {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentVisible()));

    // TMS VAD update: segment resolved
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentHidden()));
    expect(emitRegister.last, equals(SuspiciousSegmentHidden()));
    verify(mockNotificationViewModel.insert(type: .suspiciousSegment)).called(1);
    verify(mockNotificationViewModel.remove(type: .suspiciousSegment)).called(greaterThanOrEqualTo(1));
  });

  test('modelValue_whenDismissed_thenIsHidden', () async {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentVisible()));

    testAsync.run((fakeAsync) {
      testee.dismiss();
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentHidden()));
    expect(emitRegister.last, equals(SuspiciousSegmentHidden()));
    verify(mockNotificationViewModel.insert(type: .suspiciousSegment)).called(1);
    verify(mockNotificationViewModel.remove(type: .suspiciousSegment)).called(greaterThanOrEqualTo(1));
  });

  test('modelValue_whenDismissedAndPositionChangesButSegmentStillPresent_thenStaysHidden', () {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      processStreams(fakeAsync: fakeAsync);
    });

    testAsync.run((fakeAsync) {
      testee.dismiss();
      processStreams(fakeAsync: fakeAsync);
    });

    testAsync.run((fakeAsync) {
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: stopA));
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentHidden()));
  });

  test('modelValue_whenTmsVadUpdateAddsNewSuspiciousSegmentWhileJourneyOpen_thenBecomesVisible', () {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentHidden()));

    // TMS VAD update introduces a new suspicious segment
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentCD],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentVisible()));
    expect(emitRegister.last, equals(SuspiciousSegmentVisible()));
    verify(mockNotificationViewModel.insert(type: .suspiciousSegment)).called(1);
  });

  test('modelValue_whenDismissedAndTmsVadUpdateAddsNewSegment_thenBecomesVisibleAgain', () {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      processStreams(fakeAsync: fakeAsync);
    });

    testee.dismiss();
    expect(testee.modelValue, equals(SuspiciousSegmentHidden()));

    // New segment added by TMS VAD while journey is open → re-appears
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB, suspiciousSegmentCD],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentVisible()));
  });

  test('modelValue_whenNewJourneyIdentification_thenResetsState', () {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            trainIdentification: TrainIdentification(ru: .blsI, trainNumber: '1111', date: DateTime(2026)),
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      processStreams(fakeAsync: fakeAsync);
    });

    testAsync.run((fakeAsync) {
      testee.dismiss();
      processStreams(fakeAsync: fakeAsync);
    });
    expect(testee.modelValue, equals(SuspiciousSegmentHidden()));

    // New journey identification
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            trainIdentification: TrainIdentification(ru: .blsC, trainNumber: '1111', date: DateTime(2026)),
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      processStreams(fakeAsync: fakeAsync);
    });

    // After new identification, notification is visible again (dismiss was reset)
    expect(testee.modelValue, equals(SuspiciousSegmentVisible()));
  });

  test('modelValue_whenNewJourneyIdentificationWithoutSuspiciousSegments_thenIsHidden', () {
    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [suspiciousSegmentAB],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      processStreams(fakeAsync: fakeAsync);
    });

    testAsync.run((fakeAsync) {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            journeyStart: signalA,
            suspiciousSegments: [],
          ),
          data: [signalA, stopA, stopB, stopC, stopD],
        ),
      );
      processStreams(fakeAsync: fakeAsync);
    });

    expect(testee.modelValue, equals(SuspiciousSegmentHidden()));
  });
}

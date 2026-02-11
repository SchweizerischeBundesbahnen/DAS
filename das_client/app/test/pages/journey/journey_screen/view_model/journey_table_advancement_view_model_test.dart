import 'package:app/pages/journey/journey_screen/journey_table_scroll_controller.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_advancement_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_advancement_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_table_view_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../test_util.dart';
import 'journey_table_advancement_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyTableScrollController>(),
  MockSpec<JourneyTableViewModel>(),
])
void main() {
  late JourneyTableAdvancementViewModel testee;
  late MockJourneyTableViewModel mockJourneyTableViewModel;
  late BehaviorSubject<Journey?> journeySubject;
  late BehaviorSubject<JourneyPositionModel> journeyPositionSubject;
  late JourneyTableScrollController mockScrollController;
  late FakeAsync testAsync;
  late List<JourneyAdvancementModel> modelRegister;

  final journeyStart = Signal(order: 9, kilometre: []);
  final secondSignal = Signal(order: 10, kilometre: []);
  final firstServicePoint = ServicePoint(name: 'B', abbreviation: '', order: 11, kilometre: []);
  final baseJourney = Journey(
    metadata: Metadata(
      journeyStart: journeyStart,
      trainIdentification: TrainIdentification(ru: RailwayUndertaking.sbb, trainNumber: '123', date: DateTime.now()),
    ),
    data: [
      journeyStart,
      secondSignal,
      firstServicePoint,
      Signal(order: 12, kilometre: []),
      Signal(order: 19, kilometre: []),
      ServicePoint(name: 'C', abbreviation: '', order: 20, kilometre: []),
      Signal(order: 21, kilometre: []),
    ],
  );

  setUp(() {
    GetIt.I.registerSingleton(TimeConstants());
    modelRegister = [];
    mockScrollController = MockJourneyTableScrollController();

    fakeAsync((fakeAsync) {
      mockJourneyTableViewModel = MockJourneyTableViewModel();
      journeySubject = BehaviorSubject<Journey?>.seeded(baseJourney);
      when(mockJourneyTableViewModel.journey).thenAnswer((_) => journeySubject.stream);
      journeyPositionSubject = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
      testee = JourneyTableAdvancementViewModel(
        journeyTableViewModel: mockJourneyTableViewModel,
        positionStream: journeyPositionSubject.stream,
        scrollController: mockScrollController,
        onAdvancementModeChanged: [],
      );
      testee.model.listen(modelRegister.add);
      testAsync = fakeAsync;
      processStreams(fakeAsync: testAsync);
    });
    modelRegister.clear();
  });

  tearDown(() {
    reset(mockScrollController);
    modelRegister.clear();
    GetIt.I.reset();
  });

  test('toggleAdvancementMode_whenAutomatic_thenEmitsPausedWithNextAutomatic', () {
    // ACT
    testAsync.run((_) {
      testee.toggleAdvancementMode();
      processStreams(fakeAsync: testAsync);
    });

    // EXPECT
    expect(modelRegister, orderedEquals([Paused(next: Automatic())]));
  });

  test('toggleAdvancementMode_whenAutomaticAndTwice_thenEmitsPausedAndAutomatic', () {
    // ACT
    testAsync.run((_) {
      testee.toggleAdvancementMode();
      processStreams(fakeAsync: testAsync);
      testee.toggleAdvancementMode();
      processStreams(fakeAsync: testAsync);
    });

    // EXPECT
    expect(modelRegister, orderedEquals([Paused(next: Automatic()), Automatic()]));
  });

  test('toggleAdvancementMode_whenInManual_thenEmitsPausedWithNextManual', () {
    // ARRANGE
    testAsync.run((_) {
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
      modelRegister.clear();
    });

    // ACT
    testAsync.run((_) {
      testee.toggleAdvancementMode();
      processStreams(fakeAsync: testAsync);
    });

    // EXPECT
    expect(modelRegister, orderedEquals([Paused(next: Manual())]));
  });

  test('toggleAdvancementMode_whenManualAndTwice_thenEmitsPausedAndManual', () {
    // ARRANGE
    testAsync.run((_) {
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
      modelRegister.clear();
    });

    // ACT
    testAsync.run((_) {
      testee.toggleAdvancementMode();
      processStreams(fakeAsync: testAsync);
      testee.toggleAdvancementMode();
      processStreams(fakeAsync: testAsync);
    });

    // EXPECT
    expect(modelRegister, orderedEquals([Paused(next: Manual()), Manual()]));
  });

  test('toggleAdvancementMode_whenPausedAndInManual_thenScrolls', () {
    // ARRANGE
    testAsync.run((_) {
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
      testee.toggleAdvancementMode(); // toggle to Paused
      reset(mockScrollController);
    });

    // ACT
    testAsync.run((_) {
      testee.toggleAdvancementMode(); // toggle to Manual
      processStreams(fakeAsync: testAsync);
    });

    // EXPECT
    expect(modelRegister, orderedEquals([Manual(), Paused(next: Manual()), Manual()]));
    verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
  });

  test('setAdvancementModeToManual_whenPaused_thenEmitsPausedWithNextManualAndDoesNotScroll', () {
    // ARRANGE
    testAsync.run((_) {
      testee.toggleAdvancementMode(); // toggle to Paused
      processStreams(fakeAsync: testAsync);
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
      processStreams(fakeAsync: testAsync);
    });

    // ACT
    testAsync.run((_) {
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
    });

    // EXPECT
    expect(modelRegister, orderedEquals([Paused(next: Automatic()), Paused(next: Manual())]));
    verifyZeroInteractions(mockScrollController);
  });

  test('setAdvancementModeToManual_whenAutomatic_thenEmitsManualAndDoesScroll', () {
    // ACT
    testAsync.run((_) {
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
      processStreams(fakeAsync: testAsync);
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
    });

    // EXPECT
    expect(modelRegister, orderedEquals([Manual()]));
    verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(2);
  });

  test('journeyUpdate_whenJourneyIsNull_thenEmitsAutomaticAndDoesNotScroll', () {
    // ARRANGE
    testAsync.run((_) {
      testee.toggleAdvancementMode(); // PAUSED
      processStreams(fakeAsync: testAsync);
    });
    modelRegister.clear();

    // ACT
    testAsync.run((_) {
      journeySubject.add(null);
      processStreams(fakeAsync: testAsync);
    });

    // EXPECT
    expect(modelRegister, orderedEquals([Automatic()]));
    verifyZeroInteractions(mockScrollController);
  });

  test('journeyUpdate_whenCurrentPositionNull_thenDoesNotEmitAndDoesNotScroll', () {
    // EXPECT
    processStreams(fakeAsync: testAsync);
    verifyZeroInteractions(mockScrollController);
    expect(modelRegister, isEmpty);
  });

  test('journeyUpdate_whenCurrentPositionIsJourneyStart_thenDoesNotEmitAndDoesNotScroll', () {
    // ACT
    testAsync.run((_) {
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: journeyStart));
    });
    processStreams(fakeAsync: testAsync);

    // EXPECT
    verifyZeroInteractions(mockScrollController);
    expect(modelRegister, isEmpty);
  });

  test('journeyUpdate_whenCurrentPositionIsBeforeFirstServicePoint_thenDoesNotEmitAndDoesNotScroll', () {
    // ACT
    testAsync.run((_) {
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: secondSignal));
    });
    processStreams(fakeAsync: testAsync);

    // EXPECT
    verifyZeroInteractions(mockScrollController);
    expect(modelRegister, isEmpty);
  });

  test('journeyUpdate_whenCurrentPositionIsBehindFirstServicePoint_thenScrolls', () {
    // ACT
    testAsync.run((_) {
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
    });
    processStreams(fakeAsync: testAsync);

    // EXPECT
    verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
    expect(modelRegister, isEmpty);
  });

  test('journeyUpdate_whenIsInPausedManualAndSignaledPositionChanges_thenEmitsPausedWithAutomatic', () {
    // ARRANGE
    testAsync.run((_) {
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
      processStreams(fakeAsync: testAsync);
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
      testee.toggleAdvancementMode();
      processStreams(fakeAsync: testAsync);
    });
    reset(mockScrollController);
    final thirdSignal = baseJourney.data[3] as JourneyPoint;

    // ACT
    testAsync.run((_) {
      journeySubject.add(
        Journey(
          data: baseJourney.data,
          metadata: Metadata(
            signaledPosition: SignaledPosition(order: thirdSignal.order),
            trainIdentification: baseJourney.metadata.trainIdentification,
          ),
        ),
      );
      processStreams(fakeAsync: testAsync);
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: thirdSignal));
      processStreams(fakeAsync: testAsync);
    });

    // EXPECT
    verifyZeroInteractions(mockScrollController);
    expect(modelRegister, orderedEquals([Manual(), Paused(next: Manual()), Paused(next: Automatic())]));
  });

  test('journeyUpdate_whenIsInManualAndSignaledPositionChanges_thenEmitsAutomatic', () {
    // ARRANGE
    testAsync.run((_) {
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
      processStreams(fakeAsync: testAsync);
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
    });
    reset(mockScrollController);
    final thirdSignal = baseJourney.data[3] as JourneyPoint;

    // ACT
    testAsync.run((_) {
      journeySubject.add(
        Journey(
          data: baseJourney.data,
          metadata: Metadata(signaledPosition: SignaledPosition(order: thirdSignal.order)),
        ),
      );
      processStreams(fakeAsync: testAsync);
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: thirdSignal));
      processStreams(fakeAsync: testAsync);
    });

    // EXPECT
    verify(mockScrollController.scrollToJourneyPoint(thirdSignal)).called(1);
    expect(modelRegister, orderedEquals([Manual(), Automatic()]));
  });

  test('scrollToCurrentPositionIfNotPaused_whenHasNoCurrentPosition_thenDoesNotScroll', () {
    // ACT
    testee.scrollToCurrentPositionIfNotPaused();

    // EXPECT
    verifyZeroInteractions(mockScrollController);
  });

  test('scrollToCurrentPositionIfNotPaused_whenHasCurrentPositionButPaused_thenDoesNotScroll', () {
    // ARRANGE
    // ACT
    testAsync.run((_) {
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
      testee.toggleAdvancementMode();
    });
    processStreams(fakeAsync: testAsync);
    reset(mockScrollController);

    // ACT
    testee.scrollToCurrentPositionIfNotPaused();

    // EXPECT
    verifyZeroInteractions(mockScrollController);
  });

  test('scrollToCurrentPositionIfNotPaused_whenHasCurrentPositionAndAutomatic_thenDoesScroll', () {
    // ACT
    testAsync.run((_) {
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
    });
    processStreams(fakeAsync: testAsync);
    reset(mockScrollController);

    // ACT
    testee.scrollToCurrentPositionIfNotPaused();

    // EXPECT
    verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
  });

  /// Compared to the above tests, the [resetIdleScrollTimer] method has been called at least once before.
  /// This causes the idle time scrolling to be activated.
  group('tests for idle time scrolling', () {
    test('automaticIdleScrollingAfterTimeout_whenPaused_doesNotScroll', () {
      // ARRANGE
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
        testee.toggleAdvancementMode(); // to PAUSED
        processStreams(fakeAsync: testAsync);
      });

      // ACT
      testAsync.run((async) {
        testee.resetIdleScrollTimer();
        async.elapse(const Duration(seconds: 11));
        processStreams(fakeAsync: testAsync);
      });

      // EXPECT
      verifyZeroInteractions(mockScrollController);
    });

    test('automaticIdleScrollingAfterTimeout_whenOutsideOfAutomaticScrollingZone_doesNotScroll', () {
      // ARRANGE
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[1] as JourneyPoint));
        processStreams(fakeAsync: testAsync);
      });

      // ACT
      testAsync.run((async) {
        testee.resetIdleScrollTimer();
        async.elapse(const Duration(seconds: 11));
        processStreams(fakeAsync: testAsync);
      });

      // EXPECT
      verifyZeroInteractions(mockScrollController);
    });

    test('automaticIdleScrollingAfterTimeout_whenAutomaticAndInScrollingZone_doesScroll', () {
      // ARRANGE
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
        processStreams(fakeAsync: testAsync);
      });
      reset(mockScrollController);

      // ACT
      testAsync.run((async) {
        testee.resetIdleScrollTimer();
        async.elapse(const Duration(seconds: 11));
        processStreams(fakeAsync: testAsync);
      });

      // EXPECT
      verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
    });

    test('automaticIdleScrollingAfterTimeout_whenManualAndInScrollingZone_doesScroll', () {
      // ARRANGE
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
        testee.setAdvancementModeToManual(); // MANUAL
        processStreams(fakeAsync: testAsync);
      });
      reset(mockScrollController);

      // ACT
      testAsync.run((async) {
        testee.resetIdleScrollTimer();
        async.elapse(const Duration(seconds: 11));
        processStreams(fakeAsync: testAsync);
      });

      // EXPECT
      verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
    });

    test('automaticIdleScrollingAfterTimeout_whenJourneyUpdateInIdleScrollTiming_doesNOTScroll', () {
      // ARRANGE
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
        processStreams(fakeAsync: testAsync);
      });
      reset(mockScrollController);

      // ACT
      testAsync.run((async) {
        testee.resetIdleScrollTimer();
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[3] as JourneyPoint));
        processStreams(fakeAsync: testAsync);
      });

      // EXPECT
      verifyZeroInteractions(mockScrollController);
    });

    test('automaticIdleScrollingAfterTimeout_whenAdvancementModeToggledToAutomatic_doesScrollOnceAndCancelsTimer', () {
      // ARRANGE
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
        testee.toggleAdvancementMode(); // PAUSED
        testee.resetIdleScrollTimer();
        processStreams(fakeAsync: testAsync);
      });
      reset(mockScrollController);

      // ACT
      testAsync.run((async) {
        testee.toggleAdvancementMode();
        async.elapse(const Duration(seconds: 11));
        processStreams(fakeAsync: testAsync);
      });

      // EXPECT
      verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
    });
  });
}

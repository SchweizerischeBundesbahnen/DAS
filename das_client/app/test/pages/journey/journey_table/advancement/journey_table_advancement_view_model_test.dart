import 'package:app/pages/journey/journey_table/advancement/journey_advancement_model.dart';
import 'package:app/pages/journey/journey_table/advancement/journey_table_advancement_view_model.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/journey_table/journey_table_scroll_controller.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../test_util.dart';
import 'journey_table_advancement_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyTableScrollController>(),
])
void main() {
  late JourneyTableAdvancementViewModel testee;
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
    modelRegister = [];
    mockScrollController = MockJourneyTableScrollController();

    fakeAsync((fakeAsync) {
      journeySubject = BehaviorSubject<Journey?>.seeded(baseJourney);
      journeyPositionSubject = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
      testee = JourneyTableAdvancementViewModel(
        journeyStream: journeySubject.stream,
        positionStream: journeyPositionSubject.stream,
        scrollController: mockScrollController,
        onAdvancementModeToggled: () {},
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

  test('toggleAdvancementMode_whenTwice_thenEmitsPausedAndAutomatic', () {
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

  test('toggleAdvancementMode_whenInManualAndTwice_thenEmitsPausedAndManual', () {
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

  test('toggleAdvancementMode_whenPausedAndInManual_thenScrollsAfterwards', () {
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

  test('setAdvancementModeToManual_whenAutomatic_thenEmitsManualAndScrolls', () {
    // ARRANGE
    testAsync.run((_) {
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
      processStreams(fakeAsync: testAsync);
      reset(mockScrollController);
    });

    // ACT
    testAsync.run((_) {
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
    });

    // EXPECT
    expect(modelRegister, orderedEquals([Manual()]));
    verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
  });

  test('setAdvancementModeToManual_whenPaused_thenEmitsPausedWithNextManualAndDoesScroll', () {
    // ARRANGE
    testAsync.run((_) {
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
      processStreams(fakeAsync: testAsync);
      testee.toggleAdvancementMode(); // toggle to Paused
      processStreams(fakeAsync: testAsync);
      reset(mockScrollController);
    });

    // ACT
    testAsync.run((_) {
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
    });

    // EXPECT
    expect(modelRegister, orderedEquals([Paused(next: Automatic()), Paused(next: Manual())]));
    verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
  });

  test('journeyUpdate__whenJourneyIsNull_thenEmitsPausedWithNextAutomaticAndDoesNotScroll', () {
    // ACT
    testAsync.run((_) {
      journeySubject.add(null);
      processStreams(fakeAsync: testAsync);
    });

    // EXPECT
    expect(modelRegister, orderedEquals([Paused(next: Automatic())]));
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
          metadata: Metadata(signaledPosition: SignaledPosition(order: thirdSignal.order)),
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

  test('scrollToCurrentPosition_whenHasNoCurrentPosition_thenDoesNotScroll', () {
    // ACT
    testee.scrollToCurrentPosition();

    // EXPECT
    verifyZeroInteractions(mockScrollController);
  });

  test('scrollToCurrentPosition_whenHasCurrentPosition_thenDoesScroll', () {
    // ARRANGE
    // ACT
    testAsync.run((_) {
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: firstServicePoint));
    });
    processStreams(fakeAsync: testAsync);
    reset(mockScrollController);

    // ACT
    testee.scrollToCurrentPosition();

    // EXPECT
    verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
  });
}

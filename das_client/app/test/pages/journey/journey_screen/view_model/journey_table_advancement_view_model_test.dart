import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/journey_table_scroll_controller.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_advancement_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/chevron_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_advancement_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:core_data/component.dart';
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
  MockSpec<JourneyViewModel>(),
  MockSpec<DetailModalViewModel>(),
])
void main() {
  late JourneyTableAdvancementViewModel testee;
  late JourneySettingsViewModel journeySettingsViewModel;
  late MockJourneyViewModel mockJourneyViewModel;
  late MockDetailModalViewModel mockDetailModalViewModel;
  late BehaviorSubject<Journey?> journeySubject;
  late BehaviorSubject<ChevronPositionModel> chevronPositionSubject;
  late BehaviorSubject<DetailModalType?> openModalTypeSubject;
  late JourneyTableScrollController mockScrollController;
  late FakeAsync testAsync;
  late List<JourneyAdvancementModel> modelRegister;

  final journeyStart = Signal(order: 9, kilometre: []);
  final secondSignal = Signal(order: 10, kilometre: []);
  final firstServicePoint = ServicePoint(name: 'B', abbreviation: '', locationCode: '', order: 11, kilometre: []);
  final baseJourney = Journey(
    metadata: Metadata(
      trainIdentification: TrainIdentification(
        companyCode: '1285',
        trainNumber: '123',
        date: DateTime.now(),
      ),
    ),
    data: [
      journeyStart,
      secondSignal,
      firstServicePoint,
      Signal(order: 12, kilometre: []),
      Signal(order: 19, kilometre: []),
      ServicePoint(name: 'C', abbreviation: '', locationCode: '', order: 20, kilometre: []),
      Signal(order: 21, kilometre: []),
    ],
  );

  setUp(() {
    GetIt.I.registerSingleton(TimeConstants());
    modelRegister = [];
    mockScrollController = MockJourneyTableScrollController();

    fakeAsync((fakeAsync) {
      mockJourneyViewModel = MockJourneyViewModel();
      mockDetailModalViewModel = MockDetailModalViewModel();

      journeySettingsViewModel = JourneySettingsViewModel(journeyViewModel: mockJourneyViewModel);
      journeySubject = BehaviorSubject<Journey?>.seeded(baseJourney);
      when(mockJourneyViewModel.journey).thenAnswer((_) => journeySubject.stream);
      chevronPositionSubject = BehaviorSubject<ChevronPositionModel>.seeded(ChevronPositionModel());
      openModalTypeSubject = BehaviorSubject<DetailModalType?>.seeded(null);
      when(mockDetailModalViewModel.openModalType).thenAnswer((_) => openModalTypeSubject.stream);
      testee = JourneyTableAdvancementViewModel(
        journeyViewModel: mockJourneyViewModel,
        chevronPositionStream: chevronPositionSubject.stream,
        scrollController: mockScrollController,
        journeySettingsViewModel: journeySettingsViewModel,
        detailModalViewModel: mockDetailModalViewModel,
      );
      journeySettingsViewModel.model.listen((data) {
        modelRegister.add(data.journeyAdvancementModel);
      });
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
    // WHEN
    testAsync.run((_) {
      testee.toggleAdvancementMode();
      processStreams(fakeAsync: testAsync);
    });

    // THEN
    expect(modelRegister, orderedEquals([Paused(next: Automatic())]));
  });

  test('toggleAdvancementMode_whenAutomaticAndTwice_thenEmitsPausedAndAutomatic', () {
    // WHEN
    testAsync.run((_) {
      testee.toggleAdvancementMode();
      processStreams(fakeAsync: testAsync);
      testee.toggleAdvancementMode();
      processStreams(fakeAsync: testAsync);
    });

    // THEN
    expect(modelRegister, orderedEquals([Paused(next: Automatic()), Automatic()]));
  });

  test('toggleAdvancementMode_whenInManual_thenEmitsPausedWithNextManual', () {
    // GIVEN
    testAsync.run((_) {
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
      modelRegister.clear();
    });

    // WHEN
    testAsync.run((_) {
      testee.toggleAdvancementMode();
      processStreams(fakeAsync: testAsync);
    });

    // THEN
    expect(modelRegister, orderedEquals([Paused(next: Manual())]));
  });

  test('toggleAdvancementMode_whenManualAndTwice_thenEmitsPausedAndManual', () {
    // GIVEN
    testAsync.run((_) {
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
      modelRegister.clear();
    });

    // WHEN
    testAsync.run((_) {
      testee.toggleAdvancementMode();
      processStreams(fakeAsync: testAsync);
      testee.toggleAdvancementMode();
      processStreams(fakeAsync: testAsync);
    });

    // THEN
    expect(modelRegister, orderedEquals([Paused(next: Manual()), Manual()]));
  });

  test('toggleAdvancementMode_whenPausedAndInManual_thenScrolls', () {
    // GIVEN
    testAsync.run((_) {
      chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
      testee.toggleAdvancementMode(); // toggle to Paused
      reset(mockScrollController);
    });

    // WHEN
    testAsync.run((_) {
      testee.toggleAdvancementMode(); // toggle to Manual
      processStreams(fakeAsync: testAsync);
    });

    // THEN
    expect(modelRegister, orderedEquals([Manual(), Paused(next: Manual()), Manual()]));
    verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
  });

  test('setAdvancementModeToManual_whenPaused_thenEmitsPausedWithNextManualAndDoesNotScroll', () {
    // GIVEN
    testAsync.run((_) {
      testee.toggleAdvancementMode(); // toggle to Paused
      processStreams(fakeAsync: testAsync);
      chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
      processStreams(fakeAsync: testAsync);
    });

    // WHEN
    testAsync.run((_) {
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
    });

    // THEN
    expect(modelRegister, orderedEquals([Paused(next: Automatic()), Paused(next: Manual())]));
    verifyZeroInteractions(mockScrollController);
  });

  test('setAdvancementModeToManual_whenAutomatic_thenEmitsManualAndDoesScroll', () {
    // WHEN
    testAsync.run((_) {
      chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
      processStreams(fakeAsync: testAsync);
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
    });

    // THEN
    expect(modelRegister, orderedEquals([Manual()]));
    verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(2);
  });

  test('journeyUpdate_whenCurrentPositionNull_thenDoesNotEmitAndDoesNotScroll', () {
    // THEN
    processStreams(fakeAsync: testAsync);
    verifyZeroInteractions(mockScrollController);
    expect(modelRegister, isEmpty);
  });

  test('journeyUpdate_whenCurrentPositionIsJourneyStart_thenDoesNotEmitAndDoesNotScroll', () {
    // WHEN
    testAsync.run((_) {
      chevronPositionSubject.add(ChevronPositionModel(currentPosition: journeyStart));
    });
    processStreams(fakeAsync: testAsync);

    // THEN
    verifyZeroInteractions(mockScrollController);
    expect(modelRegister, isEmpty);
  });

  test('journeyUpdate_whenCurrentPositionIsBeforeFirstServicePoint_thenDoesNotEmitAndDoesNotScroll', () {
    // WHEN
    testAsync.run((_) {
      chevronPositionSubject.add(ChevronPositionModel(currentPosition: secondSignal));
    });
    processStreams(fakeAsync: testAsync);

    // THEN
    verifyZeroInteractions(mockScrollController);
    expect(modelRegister, isEmpty);
  });

  test('journeyUpdate_whenCurrentPositionIsBehindFirstServicePoint_thenScrolls', () {
    // WHEN
    testAsync.run((_) {
      chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
    });
    processStreams(fakeAsync: testAsync);

    // THEN
    verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
    expect(modelRegister, isEmpty);
  });

  test('journeyUpdate_whenIsInPausedManualAndSignaledPositionChanges_thenEmitsPausedWithAutomatic', () {
    // GIVEN
    testAsync.run((_) {
      chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
      processStreams(fakeAsync: testAsync);
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
      testee.toggleAdvancementMode();
      processStreams(fakeAsync: testAsync);
    });
    reset(mockScrollController);
    final thirdSignal = baseJourney.data[3] as JourneyPoint;

    // WHEN
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
      chevronPositionSubject.add(ChevronPositionModel(currentPosition: thirdSignal));
      processStreams(fakeAsync: testAsync);
    });

    // THEN
    verifyZeroInteractions(mockScrollController);
    expect(modelRegister, orderedEquals([Manual(), Paused(next: Manual()), Paused(next: Automatic())]));
  });

  test('journeyUpdate_whenIsInManualAndSignaledPositionChanges_thenEmitsAutomatic', () {
    // GIVEN
    testAsync.run((_) {
      chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
      processStreams(fakeAsync: testAsync);
      testee.setAdvancementModeToManual();
      processStreams(fakeAsync: testAsync);
    });
    reset(mockScrollController);
    final thirdSignal = baseJourney.data[3] as JourneyPoint;

    // WHEN
    testAsync.run((_) {
      journeySubject.add(
        Journey(
          data: baseJourney.data,
          metadata: Metadata(signaledPosition: SignaledPosition(order: thirdSignal.order)),
        ),
      );
      processStreams(fakeAsync: testAsync);
      chevronPositionSubject.add(ChevronPositionModel(currentPosition: thirdSignal));
      processStreams(fakeAsync: testAsync);
    });

    // THEN
    verify(mockScrollController.scrollToJourneyPoint(thirdSignal)).called(1);
    expect(modelRegister, orderedEquals([Manual(), Automatic()]));
  });

  test('brakeSeriesChange_whenHasCurrentPositionButPaused_thenDoesNotScroll', () {
    // GIVEN
    testAsync.run((_) {
      chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
      testee.toggleAdvancementMode();
    });
    processStreams(fakeAsync: testAsync);
    reset(mockScrollController);

    // WHEN
    testAsync.run((_) {
      journeySettingsViewModel.updateBrakeSeries(BrakeSeries(trainSeries: TrainSeries.R, brakedWeightPercentage: 150));
    });
    processStreams(fakeAsync: testAsync);

    // THEN
    verifyZeroInteractions(mockScrollController);
  });

  test('brakeSeriesChange_whenHasCurrentPosition_thenDoesScroll', () {
    // GIVEN
    testAsync.run((_) {
      chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
    });
    processStreams(fakeAsync: testAsync);
    reset(mockScrollController);

    // WHEN
    testAsync.run((_) {
      journeySettingsViewModel.updateBrakeSeries(BrakeSeries(trainSeries: TrainSeries.R, brakedWeightPercentage: 150));
    });
    processStreams(fakeAsync: testAsync);

    // THEN
    verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
  });

  test('detailModelCloses_whenHasCurrentPositionButPaused_thenDoesNotScroll', () {
    // GIVEN
    testAsync.run((_) {
      chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
      openModalTypeSubject.add(DetailModalType.servicePointModal);
      testee.toggleAdvancementMode();
    });
    processStreams(fakeAsync: testAsync);
    reset(mockScrollController);

    // WHEN
    testAsync.run((_) {
      openModalTypeSubject.add(null);
    });
    processStreams(fakeAsync: testAsync);

    // THEN
    verifyZeroInteractions(mockScrollController);
  });

  test('detailModelCloses_whenHasCurrentPosition_thenDoesScroll', () {
    // GIVEN
    testAsync.run((_) {
      chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
      openModalTypeSubject.add(DetailModalType.servicePointModal);
    });
    processStreams(fakeAsync: testAsync);
    reset(mockScrollController);

    // WHEN
    testAsync.run((_) {
      openModalTypeSubject.add(null);
    });
    processStreams(fakeAsync: testAsync);

    // THEN
    verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
  });

  /// Compared to the above tests, the [resetIdleScrollTimer] method has been called at least once before.
  /// This causes the idle time scrolling to be activated.
  group('tests for idle time scrolling', () {
    test('automaticIdleScrollingAfterTimeout_whenPaused_doesNotScroll', () {
      // GIVEN
      testAsync.run((_) {
        chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
        testee.toggleAdvancementMode(); // to PAUSED
        processStreams(fakeAsync: testAsync);
      });

      // WHEN
      testAsync.run((async) {
        testee.resetIdleScrollTimer();
        async.elapse(const Duration(seconds: 11));
        processStreams(fakeAsync: testAsync);
      });

      // THEN
      verifyZeroInteractions(mockScrollController);
    });

    test('automaticIdleScrollingAfterTimeout_whenOutsideOfAutomaticScrollingZone_doesNotScroll', () {
      // GIVEN
      testAsync.run((_) {
        chevronPositionSubject.add(ChevronPositionModel(currentPosition: baseJourney.data[1] as JourneyPoint));
        processStreams(fakeAsync: testAsync);
      });

      // WHEN
      testAsync.run((async) {
        testee.resetIdleScrollTimer();
        async.elapse(const Duration(seconds: 11));
        processStreams(fakeAsync: testAsync);
      });

      // THEN
      verifyZeroInteractions(mockScrollController);
    });

    test('automaticIdleScrollingAfterTimeout_whenAutomaticAndInScrollingZone_doesScroll', () {
      // GIVEN
      testAsync.run((_) {
        chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
        processStreams(fakeAsync: testAsync);
      });
      reset(mockScrollController);

      // WHEN
      testAsync.run((async) {
        testee.resetIdleScrollTimer();
        async.elapse(const Duration(seconds: 11));
        processStreams(fakeAsync: testAsync);
      });

      // THEN
      verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
    });

    test('automaticIdleScrollingAfterTimeout_whenManualAndInScrollingZone_doesScroll', () {
      // GIVEN
      testAsync.run((_) {
        chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
        testee.setAdvancementModeToManual(); // MANUAL
        processStreams(fakeAsync: testAsync);
      });
      reset(mockScrollController);

      // WHEN
      testAsync.run((async) {
        testee.resetIdleScrollTimer();
        async.elapse(const Duration(seconds: 11));
        processStreams(fakeAsync: testAsync);
      });

      // THEN
      verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
    });

    test('automaticIdleScrollingAfterTimeout_whenJourneyUpdateInIdleScrollTiming_doesNOTScroll', () {
      // GIVEN
      testAsync.run((_) {
        chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
        processStreams(fakeAsync: testAsync);
      });
      reset(mockScrollController);

      // WHEN
      testAsync.run((async) {
        testee.resetIdleScrollTimer();
        chevronPositionSubject.add(ChevronPositionModel(currentPosition: baseJourney.data[3] as JourneyPoint));
        processStreams(fakeAsync: testAsync);
      });

      // THEN
      verifyZeroInteractions(mockScrollController);
    });

    test('automaticIdleScrollingAfterTimeout_whenAdvancementModeToggledToAutomatic_doesScrollOnceAndCancelsTimer', () {
      // GIVEN
      testAsync.run((_) {
        chevronPositionSubject.add(ChevronPositionModel(currentPosition: firstServicePoint));
        testee.toggleAdvancementMode(); // PAUSED
        testee.resetIdleScrollTimer();
        processStreams(fakeAsync: testAsync);
      });
      reset(mockScrollController);

      // WHEN
      testAsync.run((async) {
        testee.toggleAdvancementMode();
        async.elapse(const Duration(seconds: 11));
        processStreams(fakeAsync: testAsync);
      });

      // THEN
      verify(mockScrollController.scrollToJourneyPoint(firstServicePoint)).called(1);
    });
  });
}

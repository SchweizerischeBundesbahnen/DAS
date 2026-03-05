import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:app/sound/sound.dart';
import 'package:auto_route/auto_route.dart';
import 'package:connectivity_x/component.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formation/component.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import 'brake_load_slip_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyViewModel>(),
  MockSpec<FormationRepository>(),
  MockSpec<JourneyPositionViewModel>(),
  MockSpec<JourneySettingsViewModel>(),
  MockSpec<NotificationPriorityQueueViewModel>(),
  MockSpec<BuildContext>(),
  MockSpec<StackRouter>(),
  MockSpec<StackRouterScope>(),
  MockSpec<DetailModalViewModel>(),
  MockSpec<ConnectivityManager>(),
  MockSpec<DASSounds>(),
  MockSpec<Sound>(),
])
void main() {
  late BrakeLoadSlipViewModel testee;
  late MockJourneyViewModel mockJourneyViewModel;
  late MockFormationRepository mockFormationRepository;
  late MockJourneyPositionViewModel mockJourneyPositionViewModel;
  late MockJourneySettingsViewModel mockJourneySettingsViewModel;
  late MockNotificationPriorityQueueViewModel mockNotificationViewModel;
  late MockDetailModalViewModel mockDetailModalViewModel;
  late MockConnectivityManager mockConnectivityManager;
  late MockBuildContext mockBuildContext;
  late MockStackRouter mockStackRouter;
  late MockStackRouterScope mockStackRouterScope;
  late BehaviorSubject<Journey?> journeySubject;
  late BehaviorSubject<JourneySettings> settingsSubject;
  late BehaviorSubject<JourneyPositionModel> positionSubject;
  late BehaviorSubject<Formation?> formationSubject;
  late BehaviorSubject<bool> connectivitySubject;
  late DASSounds mockDasSounds;
  late Sound mockSound;

  final trainIdentification = TrainIdentification(
    ru: RailwayUndertaking.fromCompanyCode('2185'),
    trainNumber: 'T1234',
    date: DateTime.now(),
    operatingDay: DateTime.now().add(Duration(days: -1)),
  );

  final brakeSeries = BrakeSeries(trainSeries: TrainSeries.R, brakeSeries: 150);

  final formationRun1 = _generateFormationRun(
    'CH00001',
    'CH00002',
    trainCategoryCode: brakeSeries.trainSeries.name,
    brakedWeightPercentage: brakeSeries.brakeSeries,
  );
  final formationRun2 = _generateFormationRun(
    'CH00002',
    'CH00003',
    trainCategoryCode: 'A',
    brakedWeightPercentage: 75,
  );
  final formationRun3 = _generateFormationRun('CH00003', 'CH00004', trainCategoryCode: 'N', brakedWeightPercentage: 50);

  final journey = Journey(
    metadata: Metadata(
      trainIdentification: trainIdentification,
      brakeSeries: brakeSeries,
      availableBrakeSeries: {BrakeSeries(trainSeries: TrainSeries.N, brakeSeries: 50)},
    ),
    data: [
      ServicePoint(
        name: 'A',
        abbreviation: '',
        order: 0,
        kilometre: [],
        locationCode: formationRun1.tafTapLocationReferenceStart,
      ),
      ServicePoint(
        name: 'B',
        abbreviation: '',
        order: 100,
        kilometre: [],
        locationCode: formationRun2.tafTapLocationReferenceStart,
      ),
      ServicePoint(
        name: 'C',
        abbreviation: '',
        order: 200,
        kilometre: [],
        locationCode: formationRun3.tafTapLocationReferenceStart,
      ),
    ],
  );

  final formation = Formation(
    operationalTrainNumber: trainIdentification.trainNumber,
    company: trainIdentification.ru.companyCode,
    operationalDay: trainIdentification.operatingDay!,
    formationRuns: [
      formationRun1,
      formationRun2,
      formationRun3,
    ],
  );

  setUp(() {
    mockJourneyViewModel = MockJourneyViewModel();
    mockFormationRepository = MockFormationRepository();
    mockJourneyPositionViewModel = MockJourneyPositionViewModel();
    mockDetailModalViewModel = MockDetailModalViewModel();
    mockNotificationViewModel = MockNotificationPriorityQueueViewModel();
    mockBuildContext = MockBuildContext();
    mockStackRouter = MockStackRouter();
    mockStackRouterScope = MockStackRouterScope();
    mockConnectivityManager = MockConnectivityManager();

    mockJourneySettingsViewModel = MockJourneySettingsViewModel();
    journeySubject = BehaviorSubject<Journey?>();
    settingsSubject = BehaviorSubject.seeded(
      JourneySettings(initialBrakeSeries: brakeSeries),
    );
    positionSubject = BehaviorSubject.seeded(JourneyPositionModel());
    formationSubject = BehaviorSubject<Formation?>();
    connectivitySubject = BehaviorSubject.seeded(true);

    when(mockJourneyViewModel.journey).thenAnswer((_) => journeySubject.stream);
    when(mockJourneySettingsViewModel.model).thenAnswer((_) => settingsSubject.stream);
    when(mockJourneySettingsViewModel.modelValue).thenAnswer((_) => settingsSubject.value);
    when(mockJourneyPositionViewModel.model).thenAnswer((_) => positionSubject.stream);
    when(
      mockFormationRepository.watchFormation(
        operationalTrainNumber: trainIdentification.trainNumber,
        company: trainIdentification.ru.companyCode,
        operationalDay: trainIdentification.operatingDay!,
      ),
    ).thenAnswer((_) => formationSubject.stream);
    when(mockConnectivityManager.onConnectivityChanged).thenAnswer((_) => connectivitySubject.stream);

    when(mockBuildContext.findAncestorWidgetOfExactType()).thenReturn(mockStackRouterScope);
    when(mockStackRouterScope.controller).thenReturn(mockStackRouter);

    mockDasSounds = MockDASSounds();
    mockSound = MockSound();

    when(mockDasSounds.brakeSlipUpdated).thenReturn(mockSound);
    GetIt.I.registerSingleton<DASSounds>(mockDasSounds);

    when(mockBuildContext.findAncestorWidgetOfExactType()).thenReturn(mockStackRouterScope);
    when(mockStackRouterScope.controller).thenReturn(mockStackRouter);

    testee = BrakeLoadSlipViewModel(
      journeyViewModel: mockJourneyViewModel,
      formationRepository: mockFormationRepository,
      journeyPositionViewModel: mockJourneyPositionViewModel,
      journeySettingsViewModel: mockJourneySettingsViewModel,
      notificationViewModel: mockNotificationViewModel,
      detailModalViewModel: mockDetailModalViewModel,
      connectivityManager: mockConnectivityManager,
      checkForUpdates: true,
    );
  });

  tearDown(() {
    reset(mockNotificationViewModel);
    GetIt.I.reset();
  });

  test('model_whenJourneyUpdates_repositoryWatchFormation', () async {
    journeySubject.add(journey);

    await processStreams();

    // VERIFY
    verify(
      mockFormationRepository.watchFormation(
        operationalTrainNumber: trainIdentification.trainNumber,
        company: trainIdentification.ru.companyCode,
        operationalDay: trainIdentification.operatingDay,
      ),
    ).called(1);

    testee.dispose();
  });

  test('model_whenJourneyAndFormationUpdates_emitsFormationAndFormationRun', () async {
    journeySubject.add(journey);
    formationSubject.add(formation);

    await processStreams();

    // VERIFY
    expect(
      testee.formation,
      emits(formation),
    );

    expect(
      testee.formationRun,
      emits(FormationRunChange(formationRun: formationRun1, previousFormationRun: null)),
    );
  });

  test('model_whenJourneyAndFormationUpdates_emitsFormationAndFormationRun', () async {
    journeySubject.add(journey);
    formationSubject.add(formation);

    await processStreams();

    // VERIFY
    expect(
      testee.formation,
      emits(formation),
    );

    expect(
      testee.formationRun,
      emits(FormationRunChange(formationRun: formationRun1, previousFormationRun: null)),
    );
  });

  test('model_whenPositionUpdates_emitsCorrectFormationRun', () async {
    // EXPECT LATER
    expectLater(
      testee.formation,
      emitsInOrder([null, formation]),
    );

    expectLater(
      testee.formationRun,
      emitsInOrder([
        null,
        FormationRunChange(formationRun: formationRun2, previousFormationRun: formationRun1),
        FormationRunChange(formationRun: formationRun3, previousFormationRun: formationRun2),
      ]),
    );

    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);

    final position = JourneyPositionModel(currentPosition: journey.data.whereType<ServicePoint>().elementAt(1));
    positionSubject.add(position);

    final position2 = JourneyPositionModel(currentPosition: journey.data.whereType<ServicePoint>().elementAt(2));
    positionSubject.add(position2);

    await processStreams();

    testee.dispose();
  });

  test('model_whenUsingNavigationButtons_emitCorrectFormationRun', () async {
    // EXPECT LATER
    expectLater(
      testee.formationRun,
      emitsInOrder([
        null,
        FormationRunChange(formationRun: formationRun1, previousFormationRun: null),
        FormationRunChange(formationRun: formationRun2, previousFormationRun: formationRun1),
        FormationRunChange(formationRun: formationRun3, previousFormationRun: formationRun2),
        FormationRunChange(formationRun: formationRun2, previousFormationRun: formationRun1),
      ]),
    );

    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);

    await processStreams();

    testee.previous(); // Should stay at formationRun1
    testee.next(); // Move to formationRun2
    testee.next(); // Move to formationRun3
    testee.next(); // Should stay at formationRun3
    testee.previous(); // Move to formationRun2

    testee.dispose();
  });

  test('resolveStationName_whenStationFound_returnsServicePointName', () async {
    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);

    await processStreams();

    expect(
      testee.resolveStationName(formationRun1.tafTapLocationReferenceStart),
      journey.data.whereType<ServicePoint>().first.name,
    );
    expect(
      testee.resolveStationName(formationRun2.tafTapLocationReferenceStart),
      journey.data.whereType<ServicePoint>().elementAt(1).name,
    );
  });

  test('resolveStationName_whenStationUnkown_returnsTafTapLocationCode', () async {
    final unknownTafTapCode = 'CH99999';

    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);

    await processStreams();

    expect(
      testee.resolveStationName(unknownTafTapCode),
      unknownTafTapCode,
    );
  });

  test('isJourneyAndActiveFormationRunBrakeSeriesDifferent_whenBrakeSeriesIsSame_returnsFalse', () async {
    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);

    await processStreams();

    expect(
      testee.isJourneyAndActiveFormationRunBrakeSeriesDifferent(),
      isFalse,
    );
  });

  test('isJourneyAndActiveFormationRunBrakeSeriesDifferent_whenBrakeSeriesIsDifferent_returnsTrue', () async {
    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);
    final position = JourneyPositionModel(currentPosition: journey.data.whereType<ServicePoint>().elementAt(1));
    positionSubject.add(position);

    await processStreams();

    expect(
      testee.isJourneyAndActiveFormationRunBrakeSeriesDifferent(),
      isTrue,
    );
  });

  test('canApplyActiveFormationRunBrakeSeriesToJourney_whenBrakeSeriesIsSame_returnsFalse', () async {
    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);

    await processStreams();

    expect(
      testee.canApplyActiveFormationRunBrakeSeriesToJourney(),
      isFalse,
    );
  });

  test('canApplyActiveFormationRunBrakeSeriesToJourney_whenBrakeSeriesIsDifferentButNotPresent_returnsFalse', () async {
    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);

    await processStreams();

    final position = JourneyPositionModel(currentPosition: journey.data.whereType<ServicePoint>().elementAt(1));
    positionSubject.add(position);

    await processStreams();

    expect(
      testee.canApplyActiveFormationRunBrakeSeriesToJourney(),
      isFalse,
    );
  });

  test('canApplyActiveFormationRunBrakeSeriesToJourney_whenBrakeSeriesIsDifferentAndPresent_returnsTrue', () async {
    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);

    await processStreams();

    final position = JourneyPositionModel(currentPosition: journey.data.whereType<ServicePoint>().elementAt(2));
    positionSubject.add(position);

    await processStreams();

    expect(
      testee.canApplyActiveFormationRunBrakeSeriesToJourney(),
      isTrue,
    );
  });

  test('updateJourneyBrakeSeriesFromActiveFormationRun_updatesJourneyViewModelBrakeSeries', () async {
    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);
    final position = JourneyPositionModel(currentPosition: journey.data.whereType<ServicePoint>().elementAt(1));
    positionSubject.add(position);

    await processStreams();

    expect(
      testee.isJourneyAndActiveFormationRunBrakeSeriesDifferent(),
      isTrue,
    );

    testee.updateJourneyBrakeSeriesFromActiveFormationRun();

    verify(
      mockJourneySettingsViewModel.updateBrakeSeries(BrakeSeries(trainSeries: TrainSeries.A, brakeSeries: 75)),
    ).called(1);
  });

  test('open_whenOpenIsCalled_opensFullscreenOrModal', () async {
    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);

    await processStreams();

    // Open first time (should open fullscreen)
    testee.open(mockBuildContext);

    verify(mockStackRouter.push(any)).called(1);
    verifyNever(mockDetailModalViewModel.open(any, maximize: false));

    // Open second time (should open modal)
    testee.open(mockBuildContext);

    verifyNever(mockStackRouter.push(any));
    verify(mockDetailModalViewModel.open(any, maximize: false)).called(1);

    final position = JourneyPositionModel(currentPosition: journey.data.whereType<ServicePoint>().elementAt(1));
    positionSubject.add(position);

    await processStreams();

    // FormationRun changed, should open fullscreen again
    testee.open(mockBuildContext);

    verify(mockStackRouter.push(any)).called(1);
    verifyNever(mockDetailModalViewModel.open(any, maximize: false));
  });

  test('model_whenFormationChangesBeforeNotificationDelay_emitsFormationChangedWithoutSound', () async {
    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);

    await processStreams();

    formationSubject.add(
      Formation(
        operationalTrainNumber: formation.operationalTrainNumber,
        company: formation.company,
        operationalDay: formation.operationalDay,
        formationRuns: [formationRun1, formationRun2],
      ),
    );

    await processStreams();

    expect(testee.formationValue, isNotNull);
    expect(testee.formationRunValue, isNotNull);
    verifyNever(mockNotificationViewModel.insert(type: .newBrakeLoadSlip, callback: mockSound.play));

    testee.dispose();
  });

  test('model_whenFormationChangesAfterNotificationDelay_emitsFormationChangedAndPlaysSound', () async {
    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);

    await processStreams();
    await Future.delayed(BrakeLoadSlipViewModel.initialNotificationDelay); // Wait for init delay to pass

    formationSubject.add(
      Formation(
        operationalTrainNumber: formation.operationalTrainNumber,
        company: formation.company,
        operationalDay: formation.operationalDay,
        formationRuns: [formationRun1, formationRun2],
      ),
    );

    await processStreams();

    expect(testee.formationValue, isNotNull);
    expect(testee.formationRunValue, isNotNull);
    verify(mockNotificationViewModel.insert(type: .newBrakeLoadSlip, callback: mockSound.play)).called(1);

    testee.dispose();
  });

  test('model_whenFormationUpdateIntervalElapsed_checksForFormationUpdate', () async {
    fakeAsync((fakeAsync) {
      testee.dispose();
      testee = BrakeLoadSlipViewModel(
        journeyViewModel: mockJourneyViewModel,
        formationRepository: mockFormationRepository,
        journeyPositionViewModel: mockJourneyPositionViewModel,
        journeySettingsViewModel: mockJourneySettingsViewModel,
        detailModalViewModel: mockDetailModalViewModel,
        connectivityManager: mockConnectivityManager,
        notificationViewModel: mockNotificationViewModel,
        checkForUpdates: true,
      );

      journeySubject.add(journey);
      formationSubject.add(formation);

      fakeAsync.elapse(Duration.zero);

      verifyNever(mockFormationRepository.reloadFormation(any, any, any));

      fakeAsync.elapse(Duration(minutes: 1, seconds: 30));

      verify(mockFormationRepository.reloadFormation(any, any, any)).called(1);

      testee.dispose();
    });
  });

  test('model_whenConnectivityChanges_checksForUpdates', () async {
    journeySubject.add(journey);
    formationSubject.add(formation);

    await processStreams();

    verifyNever(mockFormationRepository.reloadFormation(any, any, any));

    connectivitySubject.add(false);
    await processStreams();

    verifyNever(mockFormationRepository.reloadFormation(any, any, any));

    connectivitySubject.add(true);
    await processStreams();

    verify(mockFormationRepository.reloadFormation(any, any, any)).called(1);
  });
}

FormationRun _generateFormationRun(
  String tafTapStart,
  String tafTapEnd, {
  String? trainCategoryCode,
  int? brakedWeightPercentage,
}) {
  return FormationRun(
    inspectionDateTime: DateTime.now(),
    tafTapLocationReferenceStart: tafTapStart,
    tafTapLocationReferenceEnd: tafTapEnd,
    tractionLengthInCm: 0,
    hauledLoadLengthInCm: 0,
    formationLengthInCm: 0,
    tractionWeightInT: 0,
    hauledLoadWeightInT: 0,
    formationWeightInT: 0,
    tractionBrakedWeightInT: 0,
    hauledLoadBrakedWeightInT: 0,
    formationBrakedWeightInT: 0,
    tractionHoldingForceInHectoNewton: 0,
    hauledLoadHoldingForceInHectoNewton: 0,
    formationHoldingForceInHectoNewton: 0,
    simTrain: false,
    carCarrierVehicle: false,
    dangerousGoods: false,
    vehiclesCount: 0,
    vehiclesWithBrakeDesignLlAndKCount: 0,
    vehiclesWithBrakeDesignDCount: 0,
    vehiclesWithDisabledBrakesCount: 0,
    axleLoadMaxInKg: 0,
    gradientUphillMaxInPermille: 0,
    gradientDownhillMaxInPermille: 0,
    trainCategoryCode: trainCategoryCode,
    brakedWeightPercentage: brakedWeightPercentage,
  );
}

Future<void> processStreams() async => await Future.delayed(Duration.zero);

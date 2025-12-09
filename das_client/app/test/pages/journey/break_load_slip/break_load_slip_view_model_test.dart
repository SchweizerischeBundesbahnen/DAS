import 'package:app/pages/journey/break_load_slip/break_load_slip_view_model.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/table/config/journey_settings.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formation/component.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import 'break_load_slip_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyTableViewModel>(),
  MockSpec<FormationRepository>(),
  MockSpec<JourneyPositionViewModel>(),
  MockSpec<BuildContext>(),
  MockSpec<StackRouter>(),
  MockSpec<StackRouterScope>(),
  MockSpec<DetailModalViewModel>(),
])
void main() {
  late BreakLoadSlipViewModel testee;
  late MockJourneyTableViewModel mockJourneyTableViewModel;
  late MockFormationRepository mockFormationRepository;
  late MockJourneyPositionViewModel mockJourneyPositionViewModel;
  late MockDetailModalViewModel mockDetailModalViewModel;
  late MockBuildContext mockBuildContext;
  late MockStackRouter mockStackRouter;
  late MockStackRouterScope mockStackRouterScope;
  late BehaviorSubject<Journey?> journeySubject;
  late BehaviorSubject<JourneySettings> settingsSubject;
  late BehaviorSubject<JourneyPositionModel> positionSubject;
  late BehaviorSubject<Formation?> formationSubject;

  final trainIdentification = TrainIdentification(
    ru: RailwayUndertaking.fromCompanyCode('2185'),
    trainNumber: 'T1234',
    date: DateTime.now(),
    operatingDay: DateTime.now().add(Duration(days: -1)),
  );

  final breakSeries = BreakSeries(trainSeries: TrainSeries.R, breakSeries: 150);

  final formationRun1 = _generateFormationRun(
    'CH00001',
    'CH00002',
    trainCategoryCode: breakSeries.trainSeries.name,
    brakedWeightPercentage: breakSeries.breakSeries,
  );
  final formationRun2 = _generateFormationRun(
    'CH00002',
    'CH00003',
    trainCategoryCode: 'A',
    brakedWeightPercentage: 75,
  );
  final formationRun3 = _generateFormationRun('CH00003', 'CH00004');

  final journey = Journey(
    metadata: Metadata(trainIdentification: trainIdentification, breakSeries: breakSeries),
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
    mockJourneyTableViewModel = MockJourneyTableViewModel();
    mockFormationRepository = MockFormationRepository();
    mockJourneyPositionViewModel = MockJourneyPositionViewModel();
    mockDetailModalViewModel = MockDetailModalViewModel();
    mockBuildContext = MockBuildContext();
    mockStackRouter = MockStackRouter();
    mockStackRouterScope = MockStackRouterScope();

    journeySubject = BehaviorSubject<Journey?>();
    settingsSubject = BehaviorSubject.seeded(JourneySettings());
    positionSubject = BehaviorSubject.seeded(JourneyPositionModel());
    formationSubject = BehaviorSubject<Formation?>();

    when(mockJourneyTableViewModel.journey).thenAnswer((_) => journeySubject.stream);
    when(mockJourneyTableViewModel.settings).thenAnswer((_) => settingsSubject.stream);
    when(mockJourneyTableViewModel.settingsValue).thenAnswer((_) => settingsSubject.value);
    when(mockJourneyPositionViewModel.model).thenAnswer((_) => positionSubject.stream);
    when(
      mockFormationRepository.watchFormation(
        operationalTrainNumber: trainIdentification.trainNumber,
        company: trainIdentification.ru.companyCode,
        operationalDay: trainIdentification.operatingDay!,
      ),
    ).thenAnswer((_) => formationSubject.stream);

    when(mockBuildContext.findAncestorWidgetOfExactType()).thenReturn(mockStackRouterScope);
    when(mockStackRouterScope.controller).thenReturn(mockStackRouter);

    testee = BreakLoadSlipViewModel(
      journeyTableViewModel: mockJourneyTableViewModel,
      formationRepository: mockFormationRepository,
      journeyPositionViewModel: mockJourneyPositionViewModel,
      detailModalViewModel: mockDetailModalViewModel,
    );
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
      emits(formationRun1),
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
      emits(formationRun1),
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
      emitsInOrder([null, formationRun2, formationRun3]),
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
      emitsInOrder([null, formationRun1, formationRun2, formationRun3, formationRun2]),
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

  test('isJourneyAndActiveFormationRunBreakSeriesDifferent_whenBreakSeriesIsSame_returnsFalse', () async {
    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);

    await processStreams();

    expect(
      testee.isJourneyAndActiveFormationRunBreakSeriesDifferent(),
      isFalse,
    );
  });

  test('isJourneyAndActiveFormationRunBreakSeriesDifferent_whenBreakSeriesIsDifferent_returnsTrue', () async {
    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);
    final position = JourneyPositionModel(currentPosition: journey.data.whereType<ServicePoint>().elementAt(1));
    positionSubject.add(position);

    await processStreams();

    expect(
      testee.isJourneyAndActiveFormationRunBreakSeriesDifferent(),
      isTrue,
    );
  });

  test('updateJourneyBreakSeriesFromActiveFormationRun_updatesJourneyTableViewModelBreakSeries', () async {
    // ACT
    journeySubject.add(journey);
    formationSubject.add(formation);
    final position = JourneyPositionModel(currentPosition: journey.data.whereType<ServicePoint>().elementAt(1));
    positionSubject.add(position);

    await processStreams();

    expect(
      testee.isJourneyAndActiveFormationRunBreakSeriesDifferent(),
      isTrue,
    );

    testee.updateJourneyBreakSeriesFromActiveFormationRun();

    verify(
      mockJourneyTableViewModel.updateBreakSeries(BreakSeries(trainSeries: TrainSeries.A, breakSeries: 75)),
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

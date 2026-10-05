import 'package:app/pages/journey/journey_screen/reduced_overview/model/reduced_journey_table_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/view_model/journey_filter_view_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/view_model/reduced_overview_view_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/view_model/route_variant_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/sim_train_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../../test_util.dart';
import 'reduced_overview_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyViewModel>(),
  MockSpec<AcknowledgedModificationRepository>(),
])
void main() {
  test('model_whenJourneyEmits_thenContainsJourneyMetadata', () {
    final metadata = Metadata(timestamp: DateTime.now());
    final journeyViewModel = _setupJourneyViewModelMock(metadata, <BaseData>[]);

    final viewModel = _setupReducedOverviewViewModel(journeyViewModel: journeyViewModel);

    expect(
      viewModel.model,
      emitsInOrder([
        isA<ReducedTableLoading>(),
        isA<ReducedTableLoaded>().having((it) => it.journeyMetadata, 'journeyMetadata', metadata),
      ]),
    );
  });

  test('model_whenJourneyHasStopsAndNetworkChanges_thenEmitsOnlyMandatoryRows', () {
    // GIVEN
    final stop1 = _servicePoint(order: 100, isStop: true);
    final withoutStop = _servicePoint(order: 200);
    final stop2 = _servicePoint(order: 300, isStop: true);
    final withoutStopWithNetworkChange = _servicePoint(order: 400);
    final networkChange = CommunicationNetworkChange(communicationNetworkType: .gsmR, order: 400);
    final data = <BaseData>[stop1, withoutStop, stop2, withoutStopWithNetworkChange, networkChange];

    final communicationNetworkChanges = [networkChange];
    final metadata = Metadata(communicationNetworkChanges: communicationNetworkChanges);

    final journeyViewModel = _setupJourneyViewModelMock(metadata, data);
    final viewModel = _setupReducedOverviewViewModel(journeyViewModel: journeyViewModel);

    // WHEN
    // THEN
    expect(
      viewModel.model,
      emitsInOrder([
        isA<ReducedTableLoading>(),
        isA<ReducedTableLoaded>().having(
          (it) => it.journeyTableRowData,
          'journeyTableRowData',
          [stop1, stop2, networkChange],
        ),
      ]),
    );
  });

  test('model_whenFilterDataIsAvailable_thenAddsRelevantFilterRows', () {
    // GIVEN
    final servicePoint = _servicePoint(order: 100, isStop: true);
    final curve = CurvePoint(order: 200, kilometre: []);
    final signal = Signal(order: 300, kilometre: []);
    final protectionSection = ProtectionSection(isOptional: true, isLong: true, order: 400, kilometre: []);
    final connectionTrack = ConnectionTrack(order: 500, kilometre: []);
    final tramArea = TramArea(order: 600, kilometre: [], endKilometre: 0.0, amountTramSignals: 0);
    final whistle = Whistle(order: 700, kilometre: []);
    final speedChange = SpeedChange(order: 800, kilometre: []);
    final balise = Balise(order: 900, kilometre: [], amountLevelCrossings: 0);
    final levelCrossing = LevelCrossing(order: 1000, kilometre: []);
    final baliseLevelCrossingGroup = BaliseLevelCrossingGroup(
      order: 1100,
      kilometre: [],
      groupedElements: [],
    );
    final cabSignaling = CABSignaling(order: 1200, kilometre: []);
    final asr = AdditionalSpeedRestriction(kmFrom: 0.0, kmTo: 0.0, orderFrom: 1300, orderTo: 1400);
    final asrData = AdditionalSpeedRestrictionData(restrictions: [asr], order: 1300, kilometre: []);

    final data = <BaseData>[
      servicePoint,
      curve,
      signal,
      protectionSection,
      connectionTrack,
      tramArea,
      whistle,
      speedChange,
      balise,
      levelCrossing,
      baliseLevelCrossingGroup,
      cabSignaling,
      asrData,
    ];
    final journeyViewModel = _setupJourneyViewModelMock(Metadata(), data);
    final viewModel = _setupReducedOverviewViewModel(journeyViewModel: journeyViewModel);

    // WHEN
    // THEN
    expect(
      viewModel.model,
      emitsThrough(
        isA<ReducedTableLoaded>().having(
          (it) => it.journeyTableRowData,
          'journeyTableRowData',
          [servicePoint, protectionSection, asrData],
        ),
      ),
    );
  });

  test('model_whenAdjacentAsrRowsAreDuplicated_thenRemovesDuplicates', () {
    // GIVEN
    final asr1 = AdditionalSpeedRestriction(kmFrom: 0.0, kmTo: 0.0, orderFrom: 100, orderTo: 200);
    final asrData1 = AdditionalSpeedRestrictionData(restrictions: [asr1], order: 100, kilometre: []);
    final asr2 = AdditionalSpeedRestriction(kmFrom: 0.0, kmTo: 0.0, orderFrom: 300, orderTo: 400);
    final asrData2 = AdditionalSpeedRestrictionData(restrictions: [asr2], order: 200, kilometre: []);
    final data = <BaseData>[asrData1, asrData1, asrData2];
    final journeyViewModel = _setupJourneyViewModelMock(Metadata(), data);
    final viewModel = _setupReducedOverviewViewModel(journeyViewModel: journeyViewModel);

    // WHEN
    // THEN
    expect(
      viewModel.model,
      emitsThrough(
        isA<ReducedTableLoaded>().having(
          (it) => it.journeyTableRowData,
          'journeyTableRowData',
          [asrData1, asrData2],
        ),
      ),
    );
  });

  test('model_whenRouteVariantExistsWithoutStop_thenEmitsAnchorServicePoint', () {
    // GIVEN
    final bp1 = _servicePoint(name: 'A', abbreviation: 'A', locationCode: 'CH02111', order: 100);
    final bp3 = _servicePoint(name: 'B', abbreviation: 'B', locationCode: 'CH19045', order: 200);
    final bp2 = _servicePoint(name: 'C', abbreviation: 'C', locationCode: 'CH02125', order: 300);
    final journeyViewModel = _setupJourneyViewModelMock(Metadata(), <BaseData>[bp1, bp3, bp2]);
    final viewModel = _setupReducedOverviewViewModel(journeyViewModel: journeyViewModel);

    // WHEN
    // THEN
    expect(
      viewModel.model,
      emitsThrough(
        isA<ReducedTableLoaded>().having((it) => it.journeyTableRowData, 'journeyTableRowData', [bp2]),
      ),
    );
  });

  test('model_whenIndicationFilterIsActive_thenHidesIndicationRows', () async {
    // GIVEN
    final journeyViewModel = MockJourneyViewModel();
    final stop = _servicePoint(name: 'S', abbreviation: 'S', locationCode: 'S', order: 100, isStop: true);
    final indication = OperationalIndication(order: 200, texts: const ['OPS']);
    final journeySubject = BehaviorSubject<Journey?>.seeded(Journey(metadata: Metadata(), data: [stop, indication]));
    when(journeyViewModel.journey).thenAnswer((_) => journeySubject.stream);

    final routeVariantViewModel = RouteVariantViewModel(journeyViewModel: journeyViewModel);
    final collapsibleRowsViewModel = _setupCollapsibleRowsViewModel(journeyViewModel);
    final acknowledgedModificationRepository = _setupAcknowledgedModificationRepositoryMock();
    final journeyFilterViewModel = _setupJourneyFilterViewModel(
      journeyViewModel,
      acknowledgedModificationRepository: acknowledgedModificationRepository,
    );
    final viewModel = ReducedOverviewViewModel(
      journeyViewModel: journeyViewModel,
      routeVariantViewModel: routeVariantViewModel,
      collapsibleRowsViewModel: collapsibleRowsViewModel,
      journeyFilterViewModel: journeyFilterViewModel,
      acknowledgedModificationRepository: acknowledgedModificationRepository,
    );

    await processStreams();

    // WHEN the indication filter is activated
    final initialFilters = journeyFilterViewModel.modelValue!;
    journeyFilterViewModel.toggleFilter(initialFilters.indication);
    await processStreams();

    // THEN optional indication rows are hidden while mandatory rows remain
    final loadedModel = viewModel.modelValue as ReducedTableLoaded;
    expect(loadedModel.journeyTableRowData, [stop]);

    await journeySubject.close();
    viewModel.dispose();
    collapsibleRowsViewModel.dispose();
    routeVariantViewModel.dispose();
    journeyFilterViewModel.dispose();
  });

  test('model_whenModificationIsAcknowledged_thenRemovesOptionalModifiedRow', () async {
    // GIVEN
    final journeyViewModel = MockJourneyViewModel();
    final stop = _servicePoint(name: 'S', abbreviation: 'S', locationCode: 'S', order: 100, isStop: true);
    final modification = Modification(identifier: 'sig-1', type: ModificationType.updated, date: DateTime.now());
    final modifiedSignal = Signal(order: 200, kilometre: const [], modification: modification);
    final journeySubject = BehaviorSubject<Journey?>.seeded(
      Journey(metadata: Metadata(), data: [stop, modifiedSignal]),
    );
    final ackSubject = BehaviorSubject<Set<Modification>>.seeded({});

    when(journeyViewModel.journey).thenAnswer((_) => journeySubject.stream);

    final acknowledgedModificationRepository = _setupAcknowledgedModificationRepositoryMock(const {}, ackSubject);
    final journeySettingsViewModel = JourneySettingsViewModel(journeyViewModel: journeyViewModel);

    final routeVariantViewModel = RouteVariantViewModel(journeyViewModel: journeyViewModel);
    final collapsibleRowsViewModel = _setupCollapsibleRowsViewModel(journeyViewModel);
    final journeyFilterViewModel = JourneyFilterViewModel(
      journeyViewModel: journeyViewModel,
      acknowledgedModificationRepository: acknowledgedModificationRepository,
      journeySettingsViewModel: journeySettingsViewModel,
    );
    final viewModel = ReducedOverviewViewModel(
      journeyViewModel: journeyViewModel,
      routeVariantViewModel: routeVariantViewModel,
      collapsibleRowsViewModel: collapsibleRowsViewModel,
      journeyFilterViewModel: journeyFilterViewModel,
      acknowledgedModificationRepository: acknowledgedModificationRepository,
    );

    await processStreams();

    // Initial state: modified signal is visible in table
    var loadedModel = viewModel.modelValue as ReducedTableLoaded;
    expect(loadedModel.journeyTableRowData, [stop, modifiedSignal]);
    expect(loadedModel.acknowledgedModifications, isEmpty);

    // WHEN the modification is acknowledged
    ackSubject.add({modification});
    await processStreams();

    // THEN the optional modified signal is removed from table rows and acknowledgedModifications is updated
    loadedModel = viewModel.modelValue as ReducedTableLoaded;
    expect(loadedModel.journeyTableRowData, [stop]);
    expect(loadedModel.acknowledgedModifications, {modification});

    await journeySubject.close();
    await ackSubject.close();
    viewModel.dispose();
    collapsibleRowsViewModel.dispose();
    routeVariantViewModel.dispose();
    journeyFilterViewModel.dispose();
  });

  test('model_whenModificationsFilterIsActive_thenHidesModificationRows', () async {
    // GIVEN
    final journeyViewModel = MockJourneyViewModel();
    final stop = _servicePoint(name: 'S', abbreviation: 'S', locationCode: 'S', order: 100, isStop: true);
    final modification = Modification(identifier: 'sig-1', type: ModificationType.updated, date: DateTime.now());
    final modifiedSignal = Signal(order: 200, kilometre: const [], modification: modification);
    final journeySubject = BehaviorSubject<Journey?>.seeded(
      Journey(metadata: Metadata(), data: [stop, modifiedSignal]),
    );
    when(journeyViewModel.journey).thenAnswer((_) => journeySubject.stream);

    final routeVariantViewModel = RouteVariantViewModel(journeyViewModel: journeyViewModel);
    final collapsibleRowsViewModel = _setupCollapsibleRowsViewModel(journeyViewModel);
    final acknowledgedModificationRepository = _setupAcknowledgedModificationRepositoryMock();
    final journeyFilterViewModel = _setupJourneyFilterViewModel(
      journeyViewModel,
      acknowledgedModificationRepository: acknowledgedModificationRepository,
    );
    final viewModel = ReducedOverviewViewModel(
      journeyViewModel: journeyViewModel,
      routeVariantViewModel: routeVariantViewModel,
      collapsibleRowsViewModel: collapsibleRowsViewModel,
      journeyFilterViewModel: journeyFilterViewModel,
      acknowledgedModificationRepository: acknowledgedModificationRepository,
    );

    await processStreams();

    // WHEN modifications filter is activated
    final initialFilters = journeyFilterViewModel.modelValue!;
    journeyFilterViewModel.toggleFilter(initialFilters.modifications);
    await processStreams();

    // THEN modified row is hidden while mandatory rows remain
    final loadedModel = viewModel.modelValue as ReducedTableLoaded;
    expect(loadedModel.journeyTableRowData, [stop]);

    await journeySubject.close();
    viewModel.dispose();
    collapsibleRowsViewModel.dispose();
    routeVariantViewModel.dispose();
    journeyFilterViewModel.dispose();
  });
}

MockJourneyViewModel _setupJourneyViewModelMock(Metadata metadata, List<BaseData> data) {
  final journeyViewModel = MockJourneyViewModel();
  final journey = Journey(metadata: metadata, data: data);
  when(journeyViewModel.journey).thenAnswer((_) => Stream.value(journey));
  return journeyViewModel;
}

CollapsibleRowsViewModel _setupCollapsibleRowsViewModel(JourneyViewModel journeyViewModel) {
  final simTrainViewModel = SimTrainViewModel(journeyViewModel: journeyViewModel);
  return CollapsibleRowsViewModel(
    journeyViewModel: journeyViewModel,
    simTrainViewModel: simTrainViewModel,
    journeyPositionStream: Stream.value(JourneyPositionModel()),
  );
}

AcknowledgedModificationRepository _setupAcknowledgedModificationRepositoryMock([
  Set<Modification> modifications = const {},
  BehaviorSubject<Set<Modification>>? subject,
]) {
  final repo = MockAcknowledgedModificationRepository();
  final stream = (subject ?? BehaviorSubject.seeded(modifications)).stream;
  when(repo.model).thenAnswer((_) => stream);
  when(repo.modelValue).thenAnswer((_) => subject?.value ?? modifications);
  return repo;
}

JourneyFilterViewModel _setupJourneyFilterViewModel(
  JourneyViewModel journeyViewModel, {
  AcknowledgedModificationRepository? acknowledgedModificationRepository,
  JourneySettingsViewModel? journeySettingsViewModel,
}) {
  return JourneyFilterViewModel(
    journeyViewModel: journeyViewModel,
    acknowledgedModificationRepository:
        acknowledgedModificationRepository ?? _setupAcknowledgedModificationRepositoryMock(),
    journeySettingsViewModel: journeySettingsViewModel ?? JourneySettingsViewModel(journeyViewModel: journeyViewModel),
  );
}

ReducedOverviewViewModel _setupReducedOverviewViewModel({
  required JourneyViewModel journeyViewModel,
  RouteVariantViewModel? routeVariantViewModel,
  CollapsibleRowsViewModel? collapsibleRowsViewModel,
  JourneyFilterViewModel? journeyFilterViewModel,
  AcknowledgedModificationRepository? acknowledgedModificationRepository,
}) {
  final repo = acknowledgedModificationRepository ?? _setupAcknowledgedModificationRepositoryMock();
  return ReducedOverviewViewModel(
    journeyViewModel: journeyViewModel,
    routeVariantViewModel: routeVariantViewModel ?? RouteVariantViewModel(journeyViewModel: journeyViewModel),
    collapsibleRowsViewModel: collapsibleRowsViewModel ?? _setupCollapsibleRowsViewModel(journeyViewModel),
    journeyFilterViewModel:
        journeyFilterViewModel ??
        _setupJourneyFilterViewModel(journeyViewModel, acknowledgedModificationRepository: repo),
    acknowledgedModificationRepository: repo,
  );
}

ServicePoint _servicePoint({
  String name = '',
  String abbreviation = '',
  String locationCode = '',
  int order = 0,
  List<double> kilometre = const [],
  bool isStop = false,
}) {
  return ServicePoint(
    name: name,
    abbreviation: abbreviation,
    locationCode: locationCode,
    order: order,
    kilometre: kilometre,
    isStop: isStop,
  );
}

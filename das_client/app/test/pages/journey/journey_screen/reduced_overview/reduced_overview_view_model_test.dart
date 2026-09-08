import 'package:app/pages/journey/journey_screen/reduced_overview/reduced_journey_table_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/reduced_overview_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/route_variant_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/sim_train_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/component.dart';

import 'reduced_overview_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyViewModel>(),
])
void main() {
  test('test metadata is correctly emitted', () {
    final metadata = Metadata(timestamp: DateTime.now());
    final journeyViewModel = _setupJourneyViewModelMock(metadata, <BaseData>[]);

    final viewModel = ReducedOverviewViewModel(
      journeyViewModel: journeyViewModel,
      routeVariantViewModel: RouteVariantViewModel(journeyViewModel: journeyViewModel),
      collapsibleRowsViewModel: _setupCollapsibleRowsViewModel(journeyViewModel),
    );

    expect(
      viewModel.model,
      emitsInOrder([
        isA<ReducedTableLoading>(),
        isA<ReducedTableLoaded>().having((it) => it.journeyMetadata, 'journeyMetadata', metadata),
      ]),
    );
  });

  test('test only service points with stop or communication network change are emitted', () {
    // GIVEN
    final stop1 = ServicePoint(name: '', abbreviation: '', locationCode: '', order: 100, kilometre: [], isStop: true);
    final withoutStop = ServicePoint(
      name: '',
      abbreviation: '',
      locationCode: '',
      order: 200,
      kilometre: [],
      isStop: false,
    );
    final stop2 = ServicePoint(name: '', abbreviation: '', locationCode: '', order: 300, kilometre: [], isStop: true);
    final withoutStopWithNetworkChange = ServicePoint(
      name: '',
      abbreviation: '',
      locationCode: '',
      order: 400,
      kilometre: [],
      isStop: false,
    );
    final networkChange = CommunicationNetworkChange(communicationNetworkType: .gsmR, order: 400);
    final data = <BaseData>[stop1, withoutStop, stop2, withoutStopWithNetworkChange, networkChange];

    final communicationNetworkChanges = [networkChange];
    final metadata = Metadata(communicationNetworkChanges: communicationNetworkChanges);

    final journeyViewModel = _setupJourneyViewModelMock(metadata, data);
    final viewModel = ReducedOverviewViewModel(
      journeyViewModel: journeyViewModel,
      routeVariantViewModel: RouteVariantViewModel(journeyViewModel: journeyViewModel),
      collapsibleRowsViewModel: _setupCollapsibleRowsViewModel(journeyViewModel),
    );

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

  test('test only service points and ASR are emitted', () {
    // GIVEN
    final servicePoint = ServicePoint(
      name: '',
      abbreviation: '',
      locationCode: '',
      order: 100,
      kilometre: [],
      isStop: true,
    );
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
    final viewModel = ReducedOverviewViewModel(
      journeyViewModel: journeyViewModel,
      routeVariantViewModel: RouteVariantViewModel(journeyViewModel: journeyViewModel),
      collapsibleRowsViewModel: _setupCollapsibleRowsViewModel(journeyViewModel),
    );

    // WHEN
    // THEN
    expect(
      viewModel.model,
      emitsInOrder([
        isA<ReducedTableLoading>(),
        isA<ReducedTableLoaded>().having(
          (it) => it.journeyTableRowData,
          'journeyTableRowData',
          [servicePoint, asrData],
        ),
      ]),
    );
  });

  test('test duplicated ASR are removed', () {
    // GIVEN
    final asr1 = AdditionalSpeedRestriction(kmFrom: 0.0, kmTo: 0.0, orderFrom: 100, orderTo: 200);
    final asrData1 = AdditionalSpeedRestrictionData(restrictions: [asr1], order: 100, kilometre: []);
    final asr2 = AdditionalSpeedRestriction(kmFrom: 0.0, kmTo: 0.0, orderFrom: 300, orderTo: 400);
    final asrData2 = AdditionalSpeedRestrictionData(restrictions: [asr2], order: 200, kilometre: []);
    final data = <BaseData>[asrData1, asrData1, asrData2];
    final journeyViewModel = _setupJourneyViewModelMock(Metadata(), data);
    final viewModel = ReducedOverviewViewModel(
      journeyViewModel: journeyViewModel,
      routeVariantViewModel: RouteVariantViewModel(journeyViewModel: journeyViewModel),
      collapsibleRowsViewModel: _setupCollapsibleRowsViewModel(journeyViewModel),
    );

    // WHEN
    // THEN
    expect(
      viewModel.model,
      emitsInOrder([
        isA<ReducedTableLoading>(),
        isA<ReducedTableLoaded>().having(
          (it) => it.journeyTableRowData,
          'journeyTableRowData',
          [asrData1, asrData2],
        ),
      ]),
    );
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

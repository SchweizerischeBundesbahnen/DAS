import 'package:app/pages/journey/train_journey/widgets/reduced_overview/reduced_overview_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/component.dart';

import 'reduced_overview_view_model_test.mocks.dart';

final trainIdentification = TrainIdentification(ru: RailwayUndertaking.sbbP, trainNumber: '1234', date: DateTime.now());

@GenerateNiceMocks([
  MockSpec<SferaLocalRepo>(),
])
void main() {
  test('test metadata is correctly emitted', () {
    final metadata = Metadata(timestamp: DateTime.now());
    final sferaServiceMock = _setupSferaLocalRepoMock(metadata, <BaseData>[]);

    final viewModel = ReducedOverviewViewModel(
      trainIdentification: trainIdentification,
      sferaLocalService: sferaServiceMock,
    );

    expect(viewModel.journeyMetadata, emits(metadata));
  });

  test('test only service points with stop or communication network change are emitted', () {
    // GIVEN
    final stop1 = ServicePoint(name: '', order: 100, kilometre: [], isStop: true);
    final withoutStop = ServicePoint(name: '', order: 200, kilometre: [], isStop: false);
    final stop2 = ServicePoint(name: '', order: 300, kilometre: [], isStop: true);
    final withoutStopWithNetworkChange = ServicePoint(name: '', order: 400, kilometre: [], isStop: false);
    final data = <BaseData>[stop1, withoutStop, stop2, withoutStopWithNetworkChange];

    final communicationNetworkChanges = [CommunicationNetworkChange(type: CommunicationNetworkType.gsmR, order: 400)];
    final metadata = Metadata(communicationNetworkChanges: communicationNetworkChanges);

    final sferaServiceMock = _setupSferaLocalRepoMock(metadata, data);
    final viewModel = ReducedOverviewViewModel(
      trainIdentification: trainIdentification,
      sferaLocalService: sferaServiceMock,
    );

    // WHEN
    final dataStream = viewModel.journeyData;

    // THEN
    expect(dataStream, emits([stop1, stop2, withoutStopWithNetworkChange]));
  });

  test('test only service points and ASR are emitted', () {
    // GIVEN
    final servicePoint = ServicePoint(name: '', order: 100, kilometre: [], isStop: true);
    final curve = CurvePoint(order: 200, kilometre: []);
    final signal = Signal(order: 300, kilometre: []);
    final protectionSection = ProtectionSection(isOptional: true, isLong: true, order: 400, kilometre: []);
    final connectionTrack = ConnectionTrack(order: 500, kilometre: []);
    final tramArea = TramArea(order: 600, kilometre: [], endKilometre: 0.0, amountTramSignals: 0);
    final whistle = Whistle(order: 700, kilometre: []);
    final speedChange = SpeedChange(order: 800, kilometre: [], speeds: []);
    final balise = Balise(order: 900, kilometre: [], amountLevelCrossings: 0);
    final levelCrossing = LevelCrossing(order: 1000, kilometre: []);
    final baliseLevelCrossingGroup = BaliseLevelCrossingGroup(order: 1100, kilometre: [], groupedElements: []);
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
    final sferaServiceMock = _setupSferaLocalRepoMock(Metadata(), data);
    final viewModel = ReducedOverviewViewModel(
      trainIdentification: trainIdentification,
      sferaLocalService: sferaServiceMock,
    );

    // WHEN
    final dataStream = viewModel.journeyData;

    // THEN
    expect(dataStream, emits([servicePoint, asrData]));
  });

  test('test duplicated ASR are removed', () {
    // GIVEN
    final asr1 = AdditionalSpeedRestriction(kmFrom: 0.0, kmTo: 0.0, orderFrom: 100, orderTo: 200);
    final asrData1 = AdditionalSpeedRestrictionData(restrictions: [asr1], order: 100, kilometre: []);
    final asr2 = AdditionalSpeedRestriction(kmFrom: 0.0, kmTo: 0.0, orderFrom: 300, orderTo: 400);
    final asrData2 = AdditionalSpeedRestrictionData(restrictions: [asr2], order: 200, kilometre: []);
    final data = <BaseData>[asrData1, asrData1, asrData2];
    final sferaServiceMock = _setupSferaLocalRepoMock(Metadata(), data);
    final viewModel = ReducedOverviewViewModel(
      trainIdentification: trainIdentification,
      sferaLocalService: sferaServiceMock,
    );

    // WHEN
    final dataStream = viewModel.journeyData;

    // THEN
    expect(dataStream, emits([asrData1, asrData2]));
  });
}

MockSferaLocalRepo _setupSferaLocalRepoMock(Metadata metadata, List<BaseData> data) {
  final sferaRepoMock = MockSferaLocalRepo();
  final journey = Journey(metadata: metadata, data: data);
  when(
    sferaRepoMock.journeyStream(
      company: trainIdentification.ru.companyCode,
      trainNumber: trainIdentification.trainNumber,
      startDate: trainIdentification.date,
    ),
  ).thenAnswer((_) => Stream.value(journey));
  return sferaRepoMock;
}

import 'dart:async';

import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/sfera_journey_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ru_indications/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../test_util.dart';
import 'journey_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SferaJourneyViewModel>(),
  MockSpec<RuIndicationsRepository>(),
])
void main() {
  group('JourneyViewModel', () {
    late JourneyViewModel testee;
    late MockSferaJourneyViewModel mockSferaJourneyViewModel;
    late MockRuIndicationsRepository mockRuIndicationsRepository;
    late BehaviorSubject<Journey?> sferaJourneySubject;
    Journey? currentJourney;

    setUp(() {
      mockSferaJourneyViewModel = MockSferaJourneyViewModel();
      mockRuIndicationsRepository = MockRuIndicationsRepository();
      sferaJourneySubject = BehaviorSubject<Journey?>.seeded(null);
      currentJourney = null;

      when(mockSferaJourneyViewModel.journey).thenAnswer((_) => sferaJourneySubject.stream);
      when(mockSferaJourneyViewModel.journeyValue).thenAnswer((_) => currentJourney);

      testee = JourneyViewModel(
        sferaJourneyViewModel: mockSferaJourneyViewModel,
        ruIndicationsRepository: mockRuIndicationsRepository,
      );
    });

    tearDown(() async {
      testee.dispose();
      await sferaJourneySubject.close();
    });

    test('journey_whenSferaJourneyChanges_thenLoadsAndMergesRuIndications', () async {
      // ARRANGE
      final sferaJourney = _journey(
        trainNumber: '12345',
        servicePoints: [
          _servicePoint(order: 1000, locationCode: 'CH001'),
          _servicePoint(order: 2000, locationCode: 'CH002'),
        ],
      );
      final ruIndications = [
        const RuIndication(order: 1500, title: 'RU middle', text: 'Middle text'),
        const RuIndication(order: 2000, title: 'RU same order', text: 'Same order text'),
      ];

      when(
        mockRuIndicationsRepository.fetchRuIndications(
          trainIdentification: sferaJourney.metadata.trainIdentification!,
          locationReferences: const {'CH001': 1000, 'CH002': 2000},
        ),
      ).thenAnswer((_) => Stream.value(ruIndications));

      // ACT
      currentJourney = sferaJourney;
      sferaJourneySubject.add(sferaJourney);
      await processStreams();
      await processStreams();

      // EXPECT
      verify(
        mockRuIndicationsRepository.fetchRuIndications(
          trainIdentification: sferaJourney.metadata.trainIdentification!,
          locationReferences: const {'CH001': 1000, 'CH002': 2000},
        ),
      ).called(1);

      final emittedJourney = testee.journeyValue;
      expect(emittedJourney, isNotNull);
      expect(emittedJourney!.data.length, 4);
      expect(emittedJourney.data[0], isA<ServicePoint>());
      expect(emittedJourney.data[1], ruIndications[0]);
      expect(emittedJourney.data[2], isA<ServicePoint>());
      expect(emittedJourney.data[3], ruIndications[1]);
    });

    test('journey_whenTrainChanges_thenOldRuIndicationsAreClearedImmediately', () async {
      // ARRANGE
      final firstJourney = _journey(
        trainNumber: '100',
        servicePoints: [_servicePoint(order: 1000, locationCode: 'CH001')],
      );
      final secondJourney = _journey(
        trainNumber: '200',
        servicePoints: [_servicePoint(order: 1000, locationCode: 'CH002')],
      );
      final secondJourneyController = StreamController<List<RuIndication>>();
      addTearDown(secondJourneyController.close);

      when(
        mockRuIndicationsRepository.fetchRuIndications(
          trainIdentification: firstJourney.metadata.trainIdentification!,
          locationReferences: const {'CH001': 1000},
        ),
      ).thenAnswer((_) => Stream.value([const RuIndication(order: 1100, title: 'RU old', text: 'Old text')]));
      when(
        mockRuIndicationsRepository.fetchRuIndications(
          trainIdentification: secondJourney.metadata.trainIdentification!,
          locationReferences: const {'CH002': 1000},
        ),
      ).thenAnswer((_) => secondJourneyController.stream);

      // ACT
      currentJourney = firstJourney;
      sferaJourneySubject.add(firstJourney);
      await processStreams();
      await processStreams();

      expect(testee.journeyValue!.data.whereType<RuIndication>(), isNotEmpty);

      currentJourney = secondJourney;
      sferaJourneySubject.add(secondJourney);
      await processStreams();

      // EXPECT
      final journeyAfterTrainChange = testee.journeyValue;
      expect(journeyAfterTrainChange, isNotNull);
      expect(journeyAfterTrainChange!.data.whereType<RuIndication>(), isEmpty);

      secondJourneyController.add(const [RuIndication(order: 1100, title: 'RU new', text: 'New text')]);
      await processStreams();
      expect(testee.journeyValue!.data.whereType<RuIndication>(), isNotEmpty);
    });
  });
}

Journey _journey({required String trainNumber, required List<ServicePoint> servicePoints}) {
  return Journey(
    metadata: Metadata(
      trainIdentification: TrainIdentification(
        ru: RailwayUndertaking.sbbP,
        trainNumber: trainNumber,
        date: DateTime(2026, 1, 1),
        operatingDay: DateTime(2026, 1, 2),
      ),
    ),
    data: servicePoints,
  );
}

ServicePoint _servicePoint({required int order, required String locationCode}) {
  return ServicePoint(
    name: 'ServicePoint $order',
    abbreviation: 'SP$order',
    locationCode: locationCode,
    order: order,
    kilometre: const [],
  );
}

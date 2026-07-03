import 'package:app/pages/journey/journey_screen/view_model/sim_train_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../test_util.dart';
import 'sim_train_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<JourneyViewModel>()])
void main() {
  late SimTrainViewModel testee;
  late MockJourneyViewModel mockJourneyViewModel;
  late BehaviorSubject<Journey?> journeySubject;

  Journey createJourney(String? trainNumber) {
    final metadata = trainNumber != null
        ? Metadata(
            trainIdentification: TrainIdentification(
              ru: RailwayUndertaking.sbbCH,
              trainNumber: trainNumber,
              date: DateTime(2026, 7, 1),
            ),
          )
        : Metadata();

    return Journey(metadata: metadata, data: []);
  }

  setUp(() {
    mockJourneyViewModel = MockJourneyViewModel();
    journeySubject = BehaviorSubject<Journey?>.seeded(null);
    when(mockJourneyViewModel.journey).thenAnswer((_) => journeySubject.stream);

    testee = SimTrainViewModel(journeyViewModel: mockJourneyViewModel);
  });

  tearDown(() {
    testee.dispose();
    journeySubject.close();
  });

  group('isSimTrain', () {
    test('isSimTrain_whenTrainNumberInRange43400to43799_thenReturnsTrue', () async {
      // ACT
      journeySubject.add(createJourney('43500'));
      await processStreams();

      // EXPECT
      expect(testee.isSimTrainValue, isTrue);
    });

    test('isSimTrain_whenTrainNumberInRange63400to63799_thenReturnsTrue', () async {
      // ACT
      journeySubject.add(createJourney('63600'));
      await processStreams();

      // EXPECT
      expect(testee.isSimTrainValue, isTrue);
    });

    test('isSimTrain_whenTrainNumberAt43400Boundary_thenReturnsTrue', () async {
      // ACT
      journeySubject.add(createJourney('43400'));
      await processStreams();

      // EXPECT
      expect(testee.isSimTrainValue, isTrue);
    });

    test('isSimTrain_whenTrainNumberAt43799Boundary_thenReturnsTrue', () async {
      // ACT
      journeySubject.add(createJourney('43799'));
      await processStreams();

      // EXPECT
      expect(testee.isSimTrainValue, isTrue);
    });

    test('isSimTrain_whenTrainNumberAt63400Boundary_thenReturnsTrue', () async {
      // ACT
      journeySubject.add(createJourney('63400'));
      await processStreams();

      // EXPECT
      expect(testee.isSimTrainValue, isTrue);
    });

    test('isSimTrain_whenTrainNumberAt63799Boundary_thenReturnsTrue', () async {
      // ACT
      journeySubject.add(createJourney('63799'));
      await processStreams();

      // EXPECT
      expect(testee.isSimTrainValue, isTrue);
    });

    test('isSimTrain_whenTrainNumberOutsideRanges_thenReturnsFalse', () async {
      // ACT
      journeySubject.add(createJourney('12345'));
      await processStreams();

      // EXPECT
      expect(testee.isSimTrainValue, isFalse);
    });

    test('isSimTrain_whenTrainNumberBetweenRanges_thenReturnsFalse', () async {
      // ACT
      journeySubject.add(createJourney('50000'));
      await processStreams();

      // EXPECT
      expect(testee.isSimTrainValue, isFalse);
    });

    test('isSimTrain_whenNonNumericTrainNumber_thenReturnsFalse', () async {
      // ACT
      journeySubject.add(createJourney('ABC123'));
      await processStreams();

      // EXPECT
      expect(testee.isSimTrainValue, isFalse);
    });

    test('isSimTrain_whenTrainNumberWithPrefix_thenReturnsFalse', () async {
      // ACT
      journeySubject.add(createJourney('T43500'));
      await processStreams();

      // EXPECT
      expect(testee.isSimTrainValue, isFalse);
    });

    test('isSimTrain_whenNoTrainIdentification_thenReturnsFalse', () async {
      // ACT
      journeySubject.add(createJourney(null));
      await processStreams();

      // EXPECT
      expect(testee.isSimTrainValue, isFalse);
    });

    test('isSimTrain_whenNullJourney_thenReturnsFalse', () async {
      // ACT
      journeySubject.add(null);
      await processStreams();

      // EXPECT
      expect(testee.isSimTrainValue, isFalse);
    });

    test('isSimTrain_whenJourneyChangesFromSimToNonSim_thenEmitsFalse', () async {
      // ARRANGE
      journeySubject.add(createJourney('43500'));
      await processStreams();
      expect(testee.isSimTrainValue, isTrue);

      // ACT
      journeySubject.add(createJourney('12345'));
      await processStreams();

      // EXPECT
      expect(testee.isSimTrainValue, isFalse);
    });

    test('isSimTrain_whenJourneyChangesFromNonSimToSim_thenEmitsTrue', () async {
      // ARRANGE
      journeySubject.add(createJourney('12345'));
      await processStreams();
      expect(testee.isSimTrainValue, isFalse);

      // ACT
      journeySubject.add(createJourney('63500'));
      await processStreams();

      // EXPECT
      expect(testee.isSimTrainValue, isTrue);
    });

    test('isSimTrain_whenChanged_thenEmitsOnStream', () async {
      // ARRANGE
      final emittedValues = <bool>[];
      final subscription = testee.isSimTrain.listen(emittedValues.add);
      await processStreams();
      emittedValues.clear();

      // ACT
      journeySubject.add(createJourney('43500'));
      await processStreams();

      // EXPECT
      expect(emittedValues, [isTrue]);

      await subscription.cancel();
    });

    test('isSimTrain_whenInitialized_thenDefaultsToFalse', () {
      // EXPECT
      expect(testee.isSimTrainValue, isFalse);
    });
  });
}

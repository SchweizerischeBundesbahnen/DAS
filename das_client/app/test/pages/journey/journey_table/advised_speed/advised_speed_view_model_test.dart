import 'package:app/pages/journey/journey_screen/model/advised_speed_model.dart';
import 'package:app/pages/journey/journey_screen/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/advised_speed_view_model.dart';
import 'package:app/pages/journey/view_model/journey_table_view_model.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:app/sound/sound.dart';
import 'package:app/util/time_constants.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import 'advised_speed_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyTableViewModel>(),
  MockSpec<DASSounds>(),
  MockSpec<Sound>(),
])
void main() {
  group('Unit Test Advised Speed View Model', () {
    late AdvisedSpeedViewModel testee;
    late MockJourneyTableViewModel mockJourneyTableViewModel;
    late BehaviorSubject<Journey?> journeySubject;
    late BehaviorSubject<JourneyPositionModel> journeyPositionSubject;
    late FakeAsync testAsync;
    late DASSounds mockDasSounds;
    late List<AdvisedSpeedModel> modelRegister;
    final timeConstants = TimeConstants();
    final Sound mockStartSound = MockSound();
    final Sound mockEndSound = MockSound();

    final baseJourney = Journey(
      metadata: Metadata(),
      data: [
        Signal(order: 9, kilometre: []),
        ServicePoint(name: 'B', abbreviation: '', order: 10, kilometre: []),
        Signal(order: 11, kilometre: []),
        Signal(order: 19, kilometre: []),
        ServicePoint(name: 'C', abbreviation: '', order: 20, kilometre: []),
        Signal(order: 21, kilometre: []),
        Signal(order: 29, kilometre: []),
        ServicePoint(name: 'D', abbreviation: '', order: 30, kilometre: []),
        Signal(order: 31, kilometre: []),
      ],
    );

    setUp(() {
      mockDasSounds = MockDASSounds();
      when(mockDasSounds.advisedSpeedStart).thenReturn(mockStartSound);
      when(mockDasSounds.advisedSpeedEnd).thenReturn(mockEndSound);
      GetIt.I.registerSingleton<TimeConstants>(timeConstants);
      GetIt.I.registerSingleton<DASSounds>(mockDasSounds);

      fakeAsync((fakeAsync) {
        mockJourneyTableViewModel = MockJourneyTableViewModel();
        journeySubject = BehaviorSubject<Journey?>.seeded(null);
        when(mockJourneyTableViewModel.journey).thenAnswer((_) => journeySubject.stream);
        journeyPositionSubject = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
        testAsync = fakeAsync;

        testee = AdvisedSpeedViewModel(
          journeyPositionStream: journeyPositionSubject,
          journeyTableViewModel: mockJourneyTableViewModel,
        );
        modelRegister = [];
        testee.model.listen(modelRegister.add);
        _processStreamInFakeAsync(fakeAsync);
      });
    });

    tearDown(() {
      reset(mockEndSound);
      reset(mockStartSound);
      reset(mockDasSounds);
      modelRegister.clear();
      journeySubject.close();
      journeyPositionSubject.close();
      testee.dispose();
      GetIt.I.reset();
    });

    test('whenHasNoAdvisedSpeedSegment_doesEmitDefaultInactive', () {
      // ARRANGE
      testAsync.run((_) {
        journeySubject.add(baseJourney);
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[1] as JourneyPoint));
      });

      // ACT
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(modelRegister, orderedEquals([AdvisedSpeedModel.inactive()]));
    });

    group('journey with single advised speed segment', () {
      final advisedSpeedSegment = VelocityMaxAdvisedSpeedSegment(
        startOrder: 19,
        endOrder: 29,
        endData: baseJourney.data[6],
      );
      final singleAdvisedSpeedSegmentJourney = Journey(
        metadata: Metadata(advisedSpeedSegments: [advisedSpeedSegment]),
        data: List.from(baseJourney.data),
      );

      setUp(() {
        testAsync.run((_) {
          journeySubject.add(singleAdvisedSpeedSegmentJourney);
        });
      });

      test('whenIsOutsideOfAdvisedSpeedSegment_isInactiveDoesNotEmit', () {
        // ACT
        testAsync.run((testAsync) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[1] as JourneyPoint));
          _processStreamInFakeAsync(testAsync);
        });

        // EXPECT
        expect(modelRegister, orderedEquals([AdvisedSpeedModel.inactive()]));
      });

      test('whenEntersAdvisedSpeedSegment_isActiveWithCorrectSegmentAndSoundPlayed', () {
        // ACT
        testAsync.run((testAsync) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[3] as JourneyPoint));
          _processStreamInFakeAsync(testAsync);
        });

        // EXPECT & VERIFY
        expect(
          modelRegister,
          orderedEquals([
            AdvisedSpeedModel.inactive(),
            AdvisedSpeedModel.active(segment: advisedSpeedSegment),
          ]),
        );
        verify(mockStartSound.play()).called(1);
        verifyNever(mockEndSound.play());
      });

      test('whenExitsAdvisedSpeedSegment_isEndAndSoundPlayed', () {
        // ARRANGE
        testAsync.run((testAsync) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[3] as JourneyPoint));
          _processStreamInFakeAsync(testAsync);
        });

        // ACT
        testAsync.run((testAsync) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[6] as JourneyPoint));
          _processStreamInFakeAsync(testAsync);
        });

        // EXPECT
        expect(
          modelRegister,
          orderedEquals([
            AdvisedSpeedModel.inactive(),
            AdvisedSpeedModel.active(segment: advisedSpeedSegment),
            AdvisedSpeedModel.end(),
          ]),
        );
        verify(mockEndSound.play()).called(1);
        verify(mockStartSound.play()).called(1);
      });

      test('whenExitsAdvisedSpeedSegmentAndTimerReached_isInactive', () {
        // ARRANGE
        testAsync.run((testAsync) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[3] as JourneyPoint));
          _processStreamInFakeAsync(testAsync);
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[6] as JourneyPoint));
          _processStreamInFakeAsync(testAsync);
        });

        // ACT
        testAsync.elapse(Duration(seconds: timeConstants.advisedSpeedEndDisplaySeconds));

        // EXPECT
        expect(
          modelRegister,
          orderedEquals([
            AdvisedSpeedModel.inactive(),
            AdvisedSpeedModel.active(segment: advisedSpeedSegment),
            AdvisedSpeedModel.end(),
            AdvisedSpeedModel.inactive(),
          ]),
        );
        verify(mockEndSound.play()).called(1);
        verify(mockStartSound.play()).called(1);
      });

      test('whenWithinAdvisedSegmentAndJourneyUpdateReceivedWithNoSegments_thenIsCancelledAndSoundPlayed', () {
        // ARRANGE
        testAsync.run((testAsync) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[3] as JourneyPoint));
          _processStreamInFakeAsync(testAsync);
        });

        // ACT
        testAsync.run((testAsync) {
          journeySubject.add(baseJourney);
          _processStreamInFakeAsync(testAsync);
        });

        // EXPECT
        expect(
          modelRegister,
          orderedEquals([
            AdvisedSpeedModel.inactive(),
            AdvisedSpeedModel.active(segment: advisedSpeedSegment),
            AdvisedSpeedModel.cancel(),
          ]),
        );
        verify(mockEndSound.play()).called(1);
        verify(mockStartSound.play()).called(1);
      });

      test('whenWithinAdvisedSegmentAndJourneyUpdateReceivedWithOtherSegments_thenIsCancelledAndSoundPlayed', () {
        // ARRANGE
        final otherAdvisedSegment = VelocityMaxAdvisedSpeedSegment(
          startOrder: 30,
          endOrder: 31,
          endData: baseJourney.data[8],
        );
        final updatedJourney = Journey(
          metadata: Metadata(advisedSpeedSegments: [otherAdvisedSegment]),
          data: List.from(baseJourney.data),
        );
        testAsync.run((testAsync) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[3] as JourneyPoint));
          _processStreamInFakeAsync(testAsync);
        });

        // ACT
        testAsync.run((testAsync) {
          journeySubject.add(updatedJourney);
          _processStreamInFakeAsync(testAsync);
        });

        // EXPECT
        expect(
          modelRegister,
          orderedEquals([
            AdvisedSpeedModel.inactive(),
            AdvisedSpeedModel.active(segment: advisedSpeedSegment),
            AdvisedSpeedModel.cancel(),
          ]),
        );
        verify(mockEndSound.play()).called(1);
        verify(mockStartSound.play()).called(1);
      });

      test('whenCancelledAndTimerReached_thenEmitsInactiveState', () {
        // ARRANGE
        testAsync.run((testAsync) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[3] as JourneyPoint));
          _processStreamInFakeAsync(testAsync);
        });

        // ACT
        testAsync.run((testAsync) {
          journeySubject.add(baseJourney);
          _processStreamInFakeAsync(testAsync);
        });
        testAsync.elapse(Duration(seconds: timeConstants.advisedSpeedEndDisplaySeconds));

        // EXPECT
        expect(
          modelRegister,
          orderedEquals([
            AdvisedSpeedModel.inactive(),
            AdvisedSpeedModel.active(segment: advisedSpeedSegment),
            AdvisedSpeedModel.cancel(),
            AdvisedSpeedModel.inactive(),
          ]),
        );
        verify(mockEndSound.play()).called(1);
        verify(mockStartSound.play()).called(1);
      });
    });

    group('journey with two disjoint advised speed segments', () {
      final advisedSpeedSegmentOne = VelocityMaxAdvisedSpeedSegment(
        startOrder: 10,
        endOrder: 19,
        endData: baseJourney.data[3],
      );
      final advisedSpeedSegmentTwo = VelocityMaxAdvisedSpeedSegment(
        startOrder: 21,
        endOrder: 30,
        endData: baseJourney.data[7],
      );
      final disjointAdvisedSegmentJourney = Journey(
        metadata: Metadata(
          advisedSpeedSegments: [advisedSpeedSegmentOne, advisedSpeedSegmentTwo],
        ),
        data: List.from(baseJourney.data),
      );

      setUp(() {
        testAsync.run((_) {
          journeySubject.add(disjointAdvisedSegmentJourney);
        });
      });

      test('whenLeftFirstSegmentAndEntersNext_isActiveWithCorrectSegmentAndDoesNotGoInactiveAfterTimer', () {
        // ARRANGE
        testAsync.run((testAsync) {
          // enter first
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[2] as JourneyPoint));
          _processStreamInFakeAsync(testAsync);
          // leave first
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[3] as JourneyPoint));
          _processStreamInFakeAsync(testAsync);
        });

        // ACT
        testAsync.run((testAsync) {
          // enter second
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[5] as JourneyPoint));
          _processStreamInFakeAsync(testAsync);
        });
        testAsync.elapse(Duration(seconds: timeConstants.advisedSpeedEndDisplaySeconds));

        // EXPECT
        expect(
          modelRegister,
          orderedEquals([
            AdvisedSpeedModel.inactive(),
            AdvisedSpeedModel.active(segment: advisedSpeedSegmentOne),
            AdvisedSpeedModel.end(),
            AdvisedSpeedModel.active(segment: advisedSpeedSegmentTwo),
          ]),
        );
        verify(mockEndSound.play()).called(1);
        verify(mockStartSound.play()).called(2);
      });
    });

    group('journey with two conjunct advised speed segments', () {
      final advisedSpeedSegmentOne = VelocityMaxAdvisedSpeedSegment(
        startOrder: 10,
        endOrder: 19,
        endData: baseJourney.data[3],
      );
      final advisedSpeedSegmentTwo = VelocityMaxAdvisedSpeedSegment(
        startOrder: 19,
        endOrder: 30,
        endData: baseJourney.data[7],
      );
      final disjointAdvisedSegmentJourney = Journey(
        metadata: Metadata(
          advisedSpeedSegments: [advisedSpeedSegmentOne, advisedSpeedSegmentTwo],
        ),
        data: List.from(baseJourney.data),
      );

      setUp(() {
        testAsync.run((_) {
          journeySubject.add(disjointAdvisedSegmentJourney);
        });
      });

      test('whenLeftFirstSegmentAndEntersNext_doesEmitOnlyNewActiveAndPlaysOnlyStartSound', () {
        // ARRANGE
        testAsync.run((testAsync) {
          // enter first
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[2] as JourneyPoint));
          _processStreamInFakeAsync(testAsync);
        });

        // ACT
        testAsync.run((testAsync) {
          // leave first & enter second
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: baseJourney.data[3] as JourneyPoint));
          _processStreamInFakeAsync(testAsync);
        });

        // EXPECT
        expect(
          modelRegister,
          orderedEquals([
            AdvisedSpeedModel.inactive(),
            AdvisedSpeedModel.active(segment: advisedSpeedSegmentOne),
            AdvisedSpeedModel.active(segment: advisedSpeedSegmentTwo),
          ]),
        );
        verifyNever(mockEndSound.play());
        verify(mockStartSound.play()).called(2);
      });
    });
  });
}

void _processStreamInFakeAsync(FakeAsync testAsync) => testAsync.elapse(Duration.zero);

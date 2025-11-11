import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/advised_speed_dto.dart';
import 'package:sfera/src/data/dto/enums/start_end_qualifier_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/reason_code_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_list_dto.dart';
import 'package:sfera/src/data/dto/temporary_constraints_dto.dart';
import 'package:sfera/src/data/mapper/speed_mapper.dart';

@GenerateNiceMocks([
  MockSpec<JourneyProfileDto>(),
  MockSpec<SegmentProfileDto>(),
  MockSpec<SegmentProfileReferenceDto>(),
  MockSpec<TemporaryConstraintsDto>(),
  MockSpec<AdvisedSpeedDto>(),
])
import 'speed_mapper_test.advised_multi_segment.mocks.dart';
import 'speed_mapper_test.fixtures.dart';

void main() {
  /// Three segments:
  /// 1. Segment A
  ///   ii. TempConstraint A1
  ///   ii. TempConstraint A2
  /// 2. Segment B
  ///   i. TempConstraint B1
  /// 3. Segment C
  ///   i. TempConstraint C1
  group('Unit test SpeedMapper advised speed - multi segment', () {
    final testee = SpeedMapper.advisedSpeeds;
    final mockJourneyProfile = MockJourneyProfileDto();
    final mockSegmentProfileOne = MockSegmentProfileDto();
    final mockSegmentProfileTwo = MockSegmentProfileDto();
    final mockSegmentProfileThree = MockSegmentProfileDto();
    final mockSegmentProfileReferenceOne = MockSegmentProfileReferenceDto();
    final mockSegmentProfileReferenceTwo = MockSegmentProfileReferenceDto();
    final mockSegmentProfileReferenceThree = MockSegmentProfileReferenceDto();
    final mockTemporaryConstraintA1 = MockTemporaryConstraintsDto();
    final mockTemporaryConstraintA2 = MockTemporaryConstraintsDto();
    final mockTemporaryConstraintB1 = MockTemporaryConstraintsDto();
    final mockTemporaryConstraintC1 = MockTemporaryConstraintsDto();
    final mockAdvisedSpeedA1 = MockAdvisedSpeedDto();
    final mockAdvisedSpeedA2 = MockAdvisedSpeedDto();
    final mockAdvisedSpeedB1 = MockAdvisedSpeedDto();
    final mockAdvisedSpeedC1 = MockAdvisedSpeedDto();

    setUp(() {
      when(mockSegmentProfileReferenceOne.spId).thenReturn('id1');
      when(mockSegmentProfileOne.id).thenReturn('id1');
      when(mockSegmentProfileReferenceTwo.spId).thenReturn('id2');
      when(mockSegmentProfileTwo.id).thenReturn('id2');
      when(mockSegmentProfileReferenceThree.spId).thenReturn('id3');
      when(mockSegmentProfileThree.id).thenReturn('id3');

      when(mockTemporaryConstraintA1.advisedSpeed).thenReturn(mockAdvisedSpeedA1);
      when(mockTemporaryConstraintA2.advisedSpeed).thenReturn(mockAdvisedSpeedA2);
      when(mockTemporaryConstraintB1.advisedSpeed).thenReturn(mockAdvisedSpeedB1);
      when(mockTemporaryConstraintC1.advisedSpeed).thenReturn(mockAdvisedSpeedC1);

      /// Varying type cases are handled in single segment case
      when(mockAdvisedSpeedA1.deltaSpeed).thenReturn('Irrelevant');
      when(mockAdvisedSpeedA2.deltaSpeed).thenReturn('Irrelevant');
      when(mockAdvisedSpeedB1.deltaSpeed).thenReturn('Irrelevant');
      when(mockAdvisedSpeedC1.deltaSpeed).thenReturn('Irrelevant');
    });

    tearDown(() {
      reset(mockJourneyProfile);
      reset(mockSegmentProfileOne);
      reset(mockSegmentProfileTwo);
      reset(mockSegmentProfileThree);
      reset(mockSegmentProfileReferenceOne);
      reset(mockSegmentProfileReferenceTwo);
      reset(mockSegmentProfileReferenceThree);
      reset(mockTemporaryConstraintA1);
      reset(mockTemporaryConstraintA2);
      reset(mockTemporaryConstraintB1);
      reset(mockTemporaryConstraintC1);
      reset(mockAdvisedSpeedA1);
      reset(mockAdvisedSpeedA2);
      reset(mockAdvisedSpeedB1);
      reset(mockAdvisedSpeedC1);
    });

    group('Single segment A', () {
      final journey = ThreeServicePointsWithSurroundingSignalsJourneyFixture.overOneSegment;
      final segmentProfiles = [mockSegmentProfileOne];
      setUp(() {
        when(mockJourneyProfile.segmentProfileReferences).thenReturn([mockSegmentProfileReferenceOne]);
        when(
          mockSegmentProfileReferenceOne.advisedSpeedTemporaryConstraints,
        ).thenReturn([
          mockTemporaryConstraintA1,
          mockTemporaryConstraintA2,
        ]);
        when(mockSegmentProfileOne.length).thenReturn(5050.0);
      });

      /// closed segments means they have start and end location (regardless whether they're unknown)
      group('closed segments', () {
        test('whenSegmentsDoNotOverlap_returnTwoSegments', () {
          // ARRANGE
          when(mockTemporaryConstraintA1.startLocation).thenReturn(950.0);
          when(mockTemporaryConstraintA1.endLocation).thenReturn(1050.0);
          when(mockTemporaryConstraintA2.startLocation).thenReturn(2950.0);
          when(mockTemporaryConstraintA2.endLocation).thenReturn(3050.0);

          // ACT & EXPECT
          expect(
            testee.call(mockJourneyProfile, segmentProfiles, journey),
            orderedEquals([
              VelocityMaxAdvisedSpeedSegment(
                startOrder: 950,
                endOrder: 1050,
                endData: journey[2],
                isEndDataCalculated: false,
              ),
              VelocityMaxAdvisedSpeedSegment(
                startOrder: 2950,
                endOrder: journey[5].order,
                endData: journey[5],
                isEndDataCalculated: false,
              ),
            ]),
          );
        });

        test('whenSegmentsWithDifferentValuesDoOverlap_returnTwoSegments', () {
          // ARRANGE
          when(mockTemporaryConstraintA1.startLocation).thenReturn(950.0);
          when(mockTemporaryConstraintA1.endLocation).thenReturn(3050.0);
          when(mockAdvisedSpeedA1.speed).thenReturn('80');
          when(mockAdvisedSpeedA1.reasonCode).thenReturn(ReasonCodeDto.advisedSpeedFixedTime);
          when(mockTemporaryConstraintA2.startLocation).thenReturn(2950.0);
          when(mockTemporaryConstraintA2.endLocation).thenReturn(3050.0);

          // ACT & EXPECT
          expect(
            testee.call(mockJourneyProfile, segmentProfiles, journey),
            orderedEquals([
              FixedTimeAdvisedSpeedSegment(
                startOrder: journey.first.order,
                endOrder: journey[5].order,
                speed: SingleSpeed(value: '80'),
                endData: journey[5],
                isEndDataCalculated: false,
              ),
              VelocityMaxAdvisedSpeedSegment(
                startOrder: journey[3].order,
                endOrder: journey[5].order,
                endData: journey[5],
                isEndDataCalculated: false,
              ),
            ]),
          );
        });

        test('whenSegmentsWithSameValuesDoOverlap_returnSingleSegment', () {
          // ARRANGE
          when(mockTemporaryConstraintA1.startLocation).thenReturn(950.0);
          when(mockTemporaryConstraintA1.endLocation).thenReturn(3000.0);
          when(mockTemporaryConstraintA2.startLocation).thenReturn(2950.0);
          when(mockTemporaryConstraintA2.endLocation).thenReturn(3050.0);

          // ACT & EXPECT
          expect(
            testee.call(mockJourneyProfile, segmentProfiles, journey),
            orderedEquals([
              VelocityMaxAdvisedSpeedSegment(
                startOrder: journey.first.order,
                endOrder: journey[5].order,
                endData: journey[5],
                isEndDataCalculated: false,
              ),
            ]),
          );
        });

        test('whenSegmentAContainsSegmentB_returnSingleSegment', () {
          // ARRANGE
          when(mockTemporaryConstraintA1.startLocation).thenReturn(950.0);
          when(mockTemporaryConstraintA1.endLocation).thenReturn(3050.0);
          when(mockTemporaryConstraintA2.startLocation).thenReturn(1001.0);
          when(mockTemporaryConstraintA2.endLocation).thenReturn(2950.0);

          // ACT & EXPECT
          expect(
            testee.call(mockJourneyProfile, segmentProfiles, journey),
            orderedEquals([
              VelocityMaxAdvisedSpeedSegment(
                startOrder: journey.first.order,
                endOrder: journey[5].order,
                endData: journey[5],
                isEndDataCalculated: false,
              ),
            ]),
          );
        });

        test('whenSegmentsContainWithUnknownLocationCloseToLastSP_returnSingleSegmentEndingOnLastSP', () {
          // ARRANGE
          when(mockTemporaryConstraintA1.startLocation).thenReturn(950.0);
          when(mockTemporaryConstraintA1.endLocation).thenReturn(3001.0);
          when(mockTemporaryConstraintA2.startLocation).thenReturn(1001.0);
          when(mockTemporaryConstraintA2.endLocation).thenReturn(2999.0);

          // ACT & EXPECT
          expect(
            testee.call(mockJourneyProfile, segmentProfiles, journey),
            orderedEquals([
              VelocityMaxAdvisedSpeedSegment(
                startOrder: journey.first.order,
                endOrder: journey[4].order,
                endData: journey[4],
                isEndDataCalculated: true,
              ),
            ]),
          );
        });
      });

      /// open segments: either only startLocation / endLocation or are 'WholeSP'
      ///
      /// a sequence of open segments must end up closed, otherwise they are skipped, e.g.
      /// 1. S -> & -> E             is good (well formed)
      /// 2. S -> & WholeSP & -> E   is good (well formed)
      /// 3. S ->                    is not good (not well formed)
      group('open segments', () {
        /// 1. not well formed
        test('whenHasOnlyEndAndNoStart_thenReturnsEmpty', () {
          // ARRANGE
          when(mockTemporaryConstraintA1.endLocation).thenReturn(3000.0);

          // ACT & EXPECT
          expect(testee.call(mockJourneyProfile, segmentProfiles, journey), isEmpty);
        });

        test('whenHasOnlyStartAndNoEnd_thenReturnsEmpty', () {
          // ARRANGE
          when(mockTemporaryConstraintA1.startLocation).thenReturn(1000.0);

          // ACT & EXPECT
          expect(testee.call(mockJourneyProfile, segmentProfiles, journey), isEmpty);
        });

        test('whenHasOnlyWholeSP_thenReturnsEmpty', () {
          // ARRANGE
          when(mockTemporaryConstraintA1.startEndQualifier).thenReturn(StartEndQualifierDto.wholeSp);

          // ACT & EXPECT
          expect(testee.call(mockJourneyProfile, segmentProfiles, journey), isEmpty);
        });

        /// 2. well formed
        test('whenOneSegmentStartsOtherSegmentEnds_thenReturnsCorrectSegment', () {
          // ARRANGE
          when(mockTemporaryConstraintA1.startLocation).thenReturn(950.0);
          when(mockTemporaryConstraintA2.endLocation).thenReturn(3000.0);

          // ACT & EXPECT
          expect(
            testee.call(mockJourneyProfile, segmentProfiles, journey),
            orderedEquals([
              VelocityMaxAdvisedSpeedSegment(
                startOrder: journey.first.order,
                endOrder: journey[4].order,
                endData: journey[4],
                isEndDataCalculated: false,
              ),
            ]),
          );
        });

        test('whenOneSegmentStartsOtherSegmentEndsUnknown_thenReturnsCorrectSegment', () {
          // ARRANGE
          when(mockTemporaryConstraintA1.startLocation).thenReturn(950.0);
          when(mockTemporaryConstraintA2.endLocation).thenReturn(3010.0);

          // ACT & EXPECT
          expect(
            testee.call(mockJourneyProfile, segmentProfiles, journey),
            orderedEquals([
              VelocityMaxAdvisedSpeedSegment(
                startOrder: journey.first.order,
                endOrder: journey[4].order,
                endData: journey[4],
                isEndDataCalculated: true,
              ),
            ]),
          );
        });
      });
    });

    group('two segment profiles A & B', () {
      final journey = ThreeServicePointsWithSurroundingSignalsJourneyFixture.overTwoSegments;
      final segmentProfiles = [mockSegmentProfileOne, mockSegmentProfileTwo];
      setUp(() {
        when(
          mockJourneyProfile.segmentProfileReferences,
        ).thenReturn([mockSegmentProfileReferenceOne, mockSegmentProfileReferenceTwo]);
        when(mockSegmentProfileReferenceOne.advisedSpeedTemporaryConstraints).thenReturn([mockTemporaryConstraintA1]);
        when(mockSegmentProfileReferenceTwo.advisedSpeedTemporaryConstraints).thenReturn([mockTemporaryConstraintB1]);
        when(mockSegmentProfileOne.length).thenReturn(3050.0);
        when(mockSegmentProfileTwo.length).thenReturn(1050.0);
      });

      test('whenDoNotOverlap_returnTwoSegments', () {
        // ARRANGE
        when(mockTemporaryConstraintA1.startLocation).thenReturn(950.0);
        when(mockTemporaryConstraintA1.endLocation).thenReturn(2950.0);
        when(mockTemporaryConstraintB1.startLocation).thenReturn(950.0);
        when(mockTemporaryConstraintB1.endLocation).thenReturn(1050.0);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, segmentProfiles, journey),
          orderedEquals([
            VelocityMaxAdvisedSpeedSegment(
              startOrder: journey.first.order,
              endOrder: journey[3].order,
              endData: journey[3],
              isEndDataCalculated: false,
            ),
            VelocityMaxAdvisedSpeedSegment(
              startOrder: journey[6].order,
              endOrder: journey[8].order,
              endData: journey[8],
              isEndDataCalculated: false,
            ),
          ]),
        );
      });

      test('whenOneStartsInFirstSegmentOtherEndsInNext_returnOneSegment', () {
        // ARRANGE
        when(mockTemporaryConstraintA1.startLocation).thenReturn(950.0);
        when(mockTemporaryConstraintB1.endLocation).thenReturn(1050.0);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, segmentProfiles, journey),
          orderedEquals([
            VelocityMaxAdvisedSpeedSegment(
              startOrder: journey.first.order,
              endOrder: journey[8].order,
              endData: journey[8],
              isEndDataCalculated: false,
            ),
          ]),
        );
      });
    });

    group('three segment profiles A & B & C', () {
      final journey = ThreeServicePointsWithSurroundingSignalsJourneyFixture.overThreeSegments;
      final segmentProfiles = [mockSegmentProfileOne, mockSegmentProfileTwo, mockSegmentProfileThree];
      setUp(() {
        when(
          mockJourneyProfile.segmentProfileReferences,
        ).thenReturn([
          mockSegmentProfileReferenceOne,
          mockSegmentProfileReferenceTwo,
          mockSegmentProfileReferenceThree,
        ]);

        when(mockSegmentProfileReferenceOne.advisedSpeedTemporaryConstraints).thenReturn([mockTemporaryConstraintA1]);
        when(mockSegmentProfileReferenceTwo.advisedSpeedTemporaryConstraints).thenReturn([mockTemporaryConstraintB1]);
        when(mockSegmentProfileReferenceThree.advisedSpeedTemporaryConstraints).thenReturn([mockTemporaryConstraintC1]);

        when(mockSegmentProfileOne.length).thenReturn(1050.0);
        when(mockSegmentProfileTwo.length).thenReturn(1050.0);
        when(mockSegmentProfileThree.length).thenReturn(1050.0);
      });

      test('whenDoNotOverlap_returnThreeSegments', () {
        // ARRANGE
        when(mockTemporaryConstraintA1.startLocation).thenReturn(950.0);
        when(mockTemporaryConstraintA1.endLocation).thenReturn(1050.0);
        when(mockTemporaryConstraintB1.startLocation).thenReturn(950.0);
        when(mockTemporaryConstraintB1.endLocation).thenReturn(1050.0);
        when(mockTemporaryConstraintC1.startLocation).thenReturn(950.0);
        when(mockTemporaryConstraintC1.endLocation).thenReturn(1050.0);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, segmentProfiles, journey),
          orderedEquals([
            VelocityMaxAdvisedSpeedSegment(
              startOrder: journey.first.order,
              endOrder: journey[2].order,
              endData: journey[2],
              isEndDataCalculated: false,
            ),
            VelocityMaxAdvisedSpeedSegment(
              startOrder: journey[3].order,
              endOrder: journey[5].order,
              endData: journey[5],
              isEndDataCalculated: false,
            ),
            VelocityMaxAdvisedSpeedSegment(
              startOrder: journey[6].order,
              endOrder: journey[8].order,
              endData: journey[8],
              isEndDataCalculated: false,
            ),
          ]),
        );
      });

      test('whenOneStartsInFirstSegmentOtherEndsInLastSegment_thenSkip', () {
        // ARRANGE
        when(mockTemporaryConstraintA1.startLocation).thenReturn(950.0);
        when(mockSegmentProfileReferenceTwo.advisedSpeedTemporaryConstraints).thenReturn([]);
        when(mockTemporaryConstraintC1.endLocation).thenReturn(1050.0);

        // ACT & EXPECT
        expect(testee.call(mockJourneyProfile, segmentProfiles, journey), isEmpty);
      });

      test('whenOneStartsInFirstSegmentOtherIsWholeSP_thenSkip', () {
        // ARRANGE
        when(mockTemporaryConstraintA1.startLocation).thenReturn(950.0);
        when(mockTemporaryConstraintB1.startEndQualifier).thenReturn(StartEndQualifierDto.wholeSp);

        // ACT & EXPECT
        expect(testee.call(mockJourneyProfile, segmentProfiles, journey), isEmpty);
      });

      test('whenOneStartsInFirstSegmentOtherIsWholeSPAndHasEndInLast_thenReturnCorrectSegment', () {
        // ARRANGE
        when(mockTemporaryConstraintA1.startLocation).thenReturn(950.0);
        when(mockTemporaryConstraintB1.startEndQualifier).thenReturn(StartEndQualifierDto.wholeSp);
        when(mockTemporaryConstraintC1.endLocation).thenReturn(1050.0);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, segmentProfiles, journey),
          orderedEquals([
            VelocityMaxAdvisedSpeedSegment(
              startOrder: journey.first.order,
              endOrder: journey.last.order,
              endData: journey.last,
              isEndDataCalculated: false,
            ),
          ]),
        );
      });
    });
  });
}

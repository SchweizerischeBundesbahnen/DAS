import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/advised_speed_dto.dart';
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

const _veryLargeDouble = 1_000_000_000_000.0;

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

      when(
        mockSegmentProfileReferenceOne.advisedSpeedTemporaryConstraints,
      ).thenReturn([mockTemporaryConstraintA1, mockTemporaryConstraintA2]);
      when(mockSegmentProfileReferenceTwo.advisedSpeedTemporaryConstraints).thenReturn([mockTemporaryConstraintB1]);
      when(mockSegmentProfileReferenceThree.advisedSpeedTemporaryConstraints).thenReturn([mockTemporaryConstraintC1]);

      when(mockTemporaryConstraintA1.advisedSpeed).thenReturn(mockAdvisedSpeedA1);
      when(mockTemporaryConstraintA2.advisedSpeed).thenReturn(mockAdvisedSpeedA2);
      when(mockTemporaryConstraintB1.advisedSpeed).thenReturn(mockAdvisedSpeedB1);
      when(mockTemporaryConstraintC1.advisedSpeed).thenReturn(mockAdvisedSpeedC1);

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
      final journey = SpeedMapperTestFixtures.threeServicePointsWithSurroundingSignalsJourney;
      final segmentProfiles = [mockSegmentProfileOne];
      setUp(() {
        when(mockJourneyProfile.segmentProfileReferences).thenReturn([mockSegmentProfileReferenceOne]);
        when(mockSegmentProfileOne.length).thenReturn('5050');
      });

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
              ),
              VelocityMaxAdvisedSpeedSegment(
                startOrder: 2950,
                endOrder: journey[5].order,
                endData: journey[5],
              ),
            ]),
          );
        });

        test('whenSegmentsWithDifferentValuesDoOverlap_returnTwoSegments', () {
          // ARRANGE
          when(mockTemporaryConstraintA1.startLocation).thenReturn(950.0);
          when(mockTemporaryConstraintA1.endLocation).thenReturn(3050.0);
          when(mockAdvisedSpeedA1.speed).thenReturn('80');
          when(mockAdvisedSpeedA1.reasonCode).thenReturn(ReasonCodeDto.adlFixedTime);
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
              ),
              VelocityMaxAdvisedSpeedSegment(
                startOrder: journey[3].order,
                endOrder: journey[5].order,
                endData: journey[5],
              ),
            ]),
          );
        });

        test('whenSegmentsDoOverlap_returnSingleSegment', () {
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
              ),
            ]),
          );
        });

        test('whenSegmentsContainEachOther_returnSingleSegment', () {
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
              ),
            ]),
          );
        });

        test('whenSegmentsContainWithFuzzyEndingsToLastSP_returnSingleSegmentEndingOnLastSP', () {
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
              ),
            ]),
          );
        });

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
              ),
            ]),
          );
        });

        test('whenOneSegmentStartsOtherSegmentEnds_thenReturnsCorrectSegment', () {
          // ARRANGE
          when(mockTemporaryConstraintA2.endLocation).thenReturn(3000.0);

          // ACT & EXPECT
          expect(testee.call(mockJourneyProfile, segmentProfiles, journey), isEmpty);
        });
      });
    });
  });
}

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
import 'speed_mapper_test.advised.mocks.dart';
import 'speed_mapper_test.fixtures.dart';
import 'util.dart';

const _veryLargeDouble = 1_000_000_000_000.0;

void main() {
  group('Unit test SpeedMapper advised speed', () {
    final testee = SpeedMapper.advisedSpeeds;
    late JourneyProfileDto mockJourneyProfile;
    late SegmentProfileDto mockSegmentProfile;
    late SegmentProfileReferenceDto mockSegmentProfileReference;
    late TemporaryConstraintsDto mockTemporaryConstraint;
    late AdvisedSpeedDto mockAdvisedSpeed;

    setUp(() {
      mockJourneyProfile = MockJourneyProfileDto();
      mockSegmentProfile = MockSegmentProfileDto();
      mockSegmentProfileReference = MockSegmentProfileReferenceDto();
      mockTemporaryConstraint = MockTemporaryConstraintsDto();
      mockAdvisedSpeed = MockAdvisedSpeedDto();
    });

    tearDown(() {
      reset(mockJourneyProfile);
      reset(mockSegmentProfile);
      reset(mockSegmentProfileReference);
      reset(mockTemporaryConstraint);
      reset(mockAdvisedSpeed);
    });

    group('tests when inputs are empty', () {
      test('whenNoProfileReferences_thenSkipsParsing', () {
        // ARRANGE
        when(mockJourneyProfile.segmentProfileReferences).thenReturn(List.empty());

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], SpeedMapperTestFixtures.twoSignalJourney),
          isEmpty,
        );
      });

      test('whenNoAdvisedSpeedTemporaryConstraints_thenSkipsParsing', () {
        // ARRANGE
        when(mockJourneyProfile.segmentProfileReferences).thenReturn([mockSegmentProfileReference]);
        when(mockSegmentProfileReference.spId).thenReturn('id');
        when(mockSegmentProfile.id).thenReturn('id');
        when(mockSegmentProfileReference.advisedSpeedTemporaryConstraints).thenReturn(List.empty());

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], SpeedMapperTestFixtures.twoSignalJourney),
          isEmpty,
        );
      });
    });

    group('invalid temporary constraints', () {
      setUp(() {
        when(mockJourneyProfile.segmentProfileReferences).thenReturn([mockSegmentProfileReference]);
        when(mockSegmentProfileReference.spId).thenReturn('id');
        when(mockSegmentProfile.id).thenReturn('id');
        when(mockSegmentProfileReference.advisedSpeedTemporaryConstraints).thenReturn([mockTemporaryConstraint]);
      });

      test('whenNoAdvisedSpeedInTempConstraint_thenSkipsParsing', () {
        // ARRANGE
        when(mockTemporaryConstraint.advisedSpeed).thenReturn(null); // explicit even though this is default

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], SpeedMapperTestFixtures.twoSignalJourney),
          isEmpty,
        );
      });

      test('whenSameStartAndEndLocation_thenSkipsParsing', () {
        // ARRANGE
        when(mockTemporaryConstraint.advisedSpeed).thenReturn(mockAdvisedSpeed);
        when(mockTemporaryConstraint.startLocation).thenReturn(0);
        when(mockTemporaryConstraint.endLocation).thenReturn(0);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], SpeedMapperTestFixtures.twoSignalJourney),
          isEmpty,
        );
      });

      test('whenEndLocationBeforeStartLocation_thenSkipsParsing', () {
        // ARRANGE
        when(mockTemporaryConstraint.advisedSpeed).thenReturn(mockAdvisedSpeed);
        when(mockTemporaryConstraint.startLocation).thenReturn(10);
        when(mockTemporaryConstraint.endLocation).thenReturn(0);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], SpeedMapperTestFixtures.twoSignalJourney),
          isEmpty,
        );
      });

      test('whenNoSpeedNorDeltaSpeed_thenSkipsParsing', () {
        // ARRANGE
        final endOrder = SpeedMapperTestFixtures.twoSignalJourney.last.order;
        when(mockTemporaryConstraint.advisedSpeed).thenReturn(mockAdvisedSpeed);
        when(mockTemporaryConstraint.startLocation).thenReturn(0);
        when(mockTemporaryConstraint.endLocation).thenReturn(calculateOrderInverse(0, endOrder));
        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], SpeedMapperTestFixtures.twoSignalJourney),
          isEmpty,
        );
      });

      test('whenHasSpeedButUnknownReasonCode_thenSkipsParsing', () {
        // ARRANGE
        final endOrder = SpeedMapperTestFixtures.twoSignalJourney.last.order;
        when(mockTemporaryConstraint.advisedSpeed).thenReturn(mockAdvisedSpeed);
        when(mockTemporaryConstraint.startLocation).thenReturn(0);
        when(mockTemporaryConstraint.endLocation).thenReturn(calculateOrderInverse(0, endOrder));
        when(mockAdvisedSpeed.speed).thenReturn('80');
        when(mockAdvisedSpeed.reasonCode).thenReturn(ReasonCodeDto.nationalUse10);
        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], SpeedMapperTestFixtures.twoSignalJourney),
          isEmpty,
        );
      });

      test('whenHasSpeedButEmptyReasonCode_thenSkipsParsing', () {
        // ARRANGE
        final endOrder = SpeedMapperTestFixtures.twoSignalJourney.last.order;
        when(mockTemporaryConstraint.advisedSpeed).thenReturn(mockAdvisedSpeed);
        when(mockTemporaryConstraint.startLocation).thenReturn(0);
        when(mockTemporaryConstraint.endLocation).thenReturn(calculateOrderInverse(0, endOrder));
        when(mockAdvisedSpeed.speed).thenReturn('80');
        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], SpeedMapperTestFixtures.twoSignalJourney),
          isEmpty,
        );
      });
    });

    group('simple single segment cases', () {
      final twoSignalJourney = SpeedMapperTestFixtures.twoSignalJourney;
      setUp(() {
        when(mockJourneyProfile.segmentProfileReferences).thenReturn([mockSegmentProfileReference]);
        when(mockSegmentProfileReference.spId).thenReturn('id');
        when(mockSegmentProfile.id).thenReturn('id');
        when(mockSegmentProfileReference.advisedSpeedTemporaryConstraints).thenReturn([mockTemporaryConstraint]);
        when(mockTemporaryConstraint.advisedSpeed).thenReturn(mockAdvisedSpeed);
        when(mockTemporaryConstraint.startLocation).thenReturn(calculateOrderInverse(0, twoSignalJourney.first.order));
        when(mockTemporaryConstraint.endLocation).thenReturn(calculateOrderInverse(0, twoSignalJourney.last.order));
      });

      test('whenHasNoSpeed_thenIsVelocityMaxAdvisedSpeedSegment', () {
        // ARRANGE
        when(mockAdvisedSpeed.deltaSpeed).thenReturn('IrrelevantValue');
        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], twoSignalJourney),
          orderedEquals([
            VelocityMaxAdvisedSpeedSegment(
              startOrder: twoSignalJourney.first.order,
              endOrder: twoSignalJourney.last.order,
              endData: twoSignalJourney.last,
            ),
          ]),
        );
      });

      test('whenHasSpeedAndFollowTrainReasonCode_thenIsFollowTrainAdvisedSpeedSegment', () {
        // ARRANGE
        when(mockAdvisedSpeed.speed).thenReturn('90');
        when(mockAdvisedSpeed.reasonCode).thenReturn(ReasonCodeDto.followTrain);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], twoSignalJourney),
          orderedEquals([
            FollowTrainAdvisedSpeedSegment(
              startOrder: twoSignalJourney.first.order,
              endOrder: twoSignalJourney.last.order,
              endData: twoSignalJourney.last,
              speed: SingleSpeed(value: '90'),
            ),
          ]),
        );
      });

      test('whenHasSpeedAndTrainFollowing_thenIsTrainFollowingAdvisedSpeedSegment', () {
        // ARRANGE
        when(mockAdvisedSpeed.speed).thenReturn('90');
        when(mockAdvisedSpeed.reasonCode).thenReturn(ReasonCodeDto.trainFollowing);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], twoSignalJourney),
          orderedEquals([
            TrainFollowingAdvisedSpeedSegment(
              startOrder: twoSignalJourney.first.order,
              endOrder: twoSignalJourney.last.order,
              endData: twoSignalJourney.last,
              speed: SingleSpeed(value: '90'),
            ),
          ]),
        );
      });

      test('whenHasSpeedAndFixedTime_thenIsFixedTimeAdvisedSpeedSegment', () {
        // ARRANGE
        when(mockAdvisedSpeed.speed).thenReturn('90');
        when(mockAdvisedSpeed.reasonCode).thenReturn(ReasonCodeDto.adlFixedTime);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], twoSignalJourney),
          orderedEquals([
            FixedTimeAdvisedSpeedSegment(
              startOrder: twoSignalJourney.first.order,
              endOrder: twoSignalJourney.last.order,
              endData: twoSignalJourney.last,
              speed: SingleSpeed(value: '90'),
            ),
          ]),
        );
      });
    });

    /// Unknown location means the AdvisedSpeed has start- and endLocation, but it cannot be found in the JourneyData
    /// All startLocations are strictly **before** endLocations at this point.
    ///
    /// Then six cases have to be tested (and the mirrored counterparts):
    /// 1. When both exactly midway between to SP ----> max range
    /// 2. Invalid start / end location (e.g. start on last signal / end on first signal) --> skipped
    /// 3. Between known location and adjacent calculated SP
    /// 4. Between known location and non-adjacent calculated SP
    /// 5. When both locations unknown with leading / trailing SP ---> between two calculated SPs (both directions)
    /// 6. When one location is SP ---> between SP and calculated SP (both directions)
    group('unknown location single segment cases', () {
      final journey = SpeedMapperTestFixtures.threeServicePointsWithSurroundingSignalsJourney;
      setUp(() {
        when(mockJourneyProfile.segmentProfileReferences).thenReturn([mockSegmentProfileReference]);
        when(mockSegmentProfileReference.spId).thenReturn('id');
        when(mockSegmentProfile.id).thenReturn('id');
        when(mockSegmentProfileReference.advisedSpeedTemporaryConstraints).thenReturn([mockTemporaryConstraint]);
        when(mockTemporaryConstraint.advisedSpeed).thenReturn(mockAdvisedSpeed);
        when(mockAdvisedSpeed.deltaSpeed).thenReturn('Irrelevant');
        when(
          mockSegmentProfile.length,
        ).thenReturn(ThreeServicePointsWithSurroundingSignalsJourneyFixture.length);
      });

      test('whenStartMidwayInBetweenFirstTwoAndEndMidwayInBetweenLatterTwo_thenIsBetweenFirstSPAndLastSP', () {
        // ARRANGE
        final servicePoints = journey.whereType<ServicePoint>().toList();
        when(mockTemporaryConstraint.startLocation).thenReturn(2000);
        when(mockTemporaryConstraint.endLocation).thenReturn(4000);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], journey),
          orderedEquals([
            VelocityMaxAdvisedSpeedSegment(
              startOrder: servicePoints.first.order,
              endOrder: servicePoints.last.order,
              endData: servicePoints.last,
            ),
          ]),
        );
      });

      test('whenStartOnLastSignal_thenEndCannotBeDeterminedAndIsSkipped', () {
        // ARRANGE
        final lastSignalOrder = journey.last.order;
        when(mockTemporaryConstraint.startLocation).thenReturn(calculateOrderInverse(0, lastSignalOrder));
        when(mockTemporaryConstraint.endLocation).thenReturn(_veryLargeDouble);

        // ACT & EXPECT
        expect(testee.call(mockJourneyProfile, [mockSegmentProfile], journey), isEmpty);
      });

      test('whenEndOnFirstSignal_thenStartCannotBeDeterminedAndIsSkipped', () {
        // ARRANGE
        final firstSignalOrder = journey.first.order;
        when(mockTemporaryConstraint.startLocation).thenReturn(calculateOrderInverse(0, firstSignalOrder) - 10);
        when(mockTemporaryConstraint.endLocation).thenReturn(calculateOrderInverse(0, firstSignalOrder));

        // ACT & EXPECT
        expect(testee.call(mockJourneyProfile, [mockSegmentProfile], journey), isEmpty);
      });

      test('whenStartFirstSignalAndEndCloseFirstSP_thenIsBetweenFirstSignalAndFirstSP', () {
        // ARRANGE
        final firstSignalOrder = journey.first.order;
        final firstServicePoint = journey[1];
        when(mockTemporaryConstraint.startLocation).thenReturn(calculateOrderInverse(0, firstSignalOrder));
        when(mockTemporaryConstraint.endLocation).thenReturn(calculateOrderInverse(0, firstSignalOrder) + 10);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], journey),
          orderedEquals([
            VelocityMaxAdvisedSpeedSegment(
              startOrder: firstSignalOrder,
              endOrder: firstServicePoint.order,
              endData: firstServicePoint,
            ),
          ]),
        );
      });

      test('whenEndOnLastSignalAndStartCloseSecondSP_thenIsBetweenSecondSPAndLastSignal', () {
        // ARRANGE
        final lastSignalOrder = journey.last.order;
        final servicePoints = journey.whereType<ServicePoint>().toList();
        when(mockTemporaryConstraint.startLocation).thenReturn(calculateOrderInverse(0, servicePoints[1].order) - 10);
        when(mockTemporaryConstraint.endLocation).thenReturn(calculateOrderInverse(0, lastSignalOrder));

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], journey),
          orderedEquals([
            VelocityMaxAdvisedSpeedSegment(
              startOrder: servicePoints[1].order,
              endOrder: lastSignalOrder,
              endData: journey.last,
            ),
          ]),
        );
      });

      test('whenStartCloseFirstSPAndEndCloseFirstSP_thenIsBetweenFirstSPAndSecondSP', () {
        // ARRANGE
        final servicePoints = journey.whereType<ServicePoint>().toList();
        final firstServicePointLocation = calculateOrderInverse(0, servicePoints.first.order);
        when(mockTemporaryConstraint.startLocation).thenReturn(firstServicePointLocation - 5);
        when(mockTemporaryConstraint.endLocation).thenReturn(firstServicePointLocation + 10);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], journey),
          orderedEquals([
            VelocityMaxAdvisedSpeedSegment(
              startOrder: servicePoints.first.order,
              endOrder: servicePoints[1].order,
              endData: servicePoints[1],
            ),
          ]),
        );
      });

      test('whenStartCloseLastSPAndEndCloseLastSP_thenIsBetweenSecondSPAndLastSP', () {
        // ARRANGE
        final servicePoints = journey.whereType<ServicePoint>().toList();
        final lastServicePointOrder = servicePoints.last.order;
        when(mockTemporaryConstraint.startLocation).thenReturn(calculateOrderInverse(0, lastServicePointOrder) - 10);
        when(mockTemporaryConstraint.endLocation).thenReturn(calculateOrderInverse(0, lastServicePointOrder) + 10);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], journey),
          orderedEquals([
            VelocityMaxAdvisedSpeedSegment(
              startOrder: servicePoints[1].order,
              endOrder: servicePoints.last.order,
              endData: servicePoints.last,
            ),
          ]),
        );
      });

      test('whenStartCloseToFirstSPAndEndCloseLastSP_thenIsBetweenFirstSPAndLastSP', () {
        // ARRANGE
        final servicePoints = journey.whereType<ServicePoint>().toList();
        when(mockTemporaryConstraint.startLocation).thenReturn(calculateOrderInverse(0, servicePoints.first.order) + 1);
        when(mockTemporaryConstraint.endLocation).thenReturn(calculateOrderInverse(0, servicePoints.last.order) + 1);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], journey),
          orderedEquals([
            VelocityMaxAdvisedSpeedSegment(
              startOrder: servicePoints.first.order,
              endOrder: servicePoints.last.order,
              endData: servicePoints.last,
            ),
          ]),
        );
      });

      test('whenStartFirstSPAndEndCloseFirstSP_thenIsBetweenFirstSPAndSecondSP', () {
        // ARRANGE
        final servicePoints = journey.whereType<ServicePoint>().toList();
        final firstServicePointLocation = calculateOrderInverse(0, servicePoints.first.order);
        when(mockTemporaryConstraint.startLocation).thenReturn(firstServicePointLocation);
        when(mockTemporaryConstraint.endLocation).thenReturn(firstServicePointLocation + 10);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], journey),
          orderedEquals([
            VelocityMaxAdvisedSpeedSegment(
              startOrder: servicePoints.first.order,
              endOrder: servicePoints[1].order,
              endData: servicePoints[1],
            ),
          ]),
        );
      });

      test('whenEndIsLastSPAndStartCloseLastSP_thenIsBetweenSecondSPAndLastSP', () {
        // ARRANGE
        final servicePoints = journey.whereType<ServicePoint>().toList();
        final lastServicePointLocation = calculateOrderInverse(0, servicePoints.last.order);
        when(mockTemporaryConstraint.startLocation).thenReturn(lastServicePointLocation - 10);
        when(mockTemporaryConstraint.endLocation).thenReturn(lastServicePointLocation);

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], journey),
          orderedEquals([
            VelocityMaxAdvisedSpeedSegment(
              startOrder: servicePoints[1].order,
              endOrder: servicePoints.last.order,
              endData: servicePoints.last,
            ),
          ]),
        );
      });
    });
  });
}

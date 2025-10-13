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
import 'speed_mapper_test.advised_single_segment.mocks.dart';
import 'speed_mapper_test.fixtures.dart';
import 'util.dart';

const _veryLargeDouble = 1_000_000_000_000.0;

void main() {
  group('Unit test SpeedMapper advised speed - single segment', () {
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
      test('whenNoProfileReferences_thenIsEmpty', () {
        // ARRANGE
        when(mockJourneyProfile.segmentProfileReferences).thenReturn(List.empty());

        // ACT & EXPECT
        expect(
          testee.call(mockJourneyProfile, [mockSegmentProfile], SpeedMapperTestFixtures.twoSignalJourney),
          isEmpty,
        );
      });

      test('whenNoAdvisedSpeedTemporaryConstraints_thenIsEmpty', () {
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

    group('invalid temporary constraints advised speed', () {
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

    /// Unknown location means the AdvisedSpeed has start- and endLocations, but at least one of them
    /// cannot be found in the JourneyData.
    ///
    /// All startLocations are strictly **before** endLocations at this point.
    ///
    /// Then three base cases can be differentiated:
    /// 1. Invalid start / end location (e.g. start on last signal) --> Segment is skipped
    /// 2. One known location, one unknown location
    /// 3. Both unknown locations
    group('Unknown locations', () {
      final journey = SpeedMapperTestFixtures.threeServicePointsWithSurroundingSignalsJourney;
      final servicePoints = journey.whereType<ServicePoint>().toList();
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

      group('Invalid start / end location -> AdvisedSpeed is skipped', () {
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
      });

      /// One location is known, the other unknown. Here, multiple cases can be differentiated:
      ///
      /// Known locations can be either on a service point (SP) or non SP. We abbreviate all possible cases to:
      ///
      /// 1. start is known, on **non SP**
      ///   i. end is close to adjacent SP
      ///   ii. end is close to non-adjacent SP (SP in between)
      ///   iii. end is midway between adjacent SP and next SP
      ///   iv. end is midway between non adjacent SP and next SP
      /// 2. end is known, **on SP**
      ///   i. start is close to adjacent SP
      ///   ii. start is close to non-adjacent SP (SP in between)
      ///   iii. start is midway between adjacent SP and next SP
      ///   iv. start is midway between non adjacent SP and next SP
      /// 3. both end up being close to the **same SP** --> skipped
      group('One location is known', () {
        /// start known on first signal
        test('whenEndCloseFirstSP_thenIsBetweenFirstSignalAndFirstSP', () {
          // ARRANGE
          final firstSignalOrder = journey.first.order;
          when(mockTemporaryConstraint.startLocation).thenReturn(calculateOrderInverse(0, firstSignalOrder));
          when(mockTemporaryConstraint.endLocation).thenReturn(calculateOrderInverse(0, firstSignalOrder) + 10);

          // ACT & EXPECT
          expect(
            testee.call(mockJourneyProfile, [mockSegmentProfile], journey),
            orderedEquals([
              VelocityMaxAdvisedSpeedSegment(
                startOrder: firstSignalOrder,
                endOrder: servicePoints.first.order,
                endData: servicePoints.first,
              ),
            ]),
          );
        });

        test('whenEndCloseSecondSP_thenIsBetweenFirstSignalAndSecondSP', () {
          // ARRANGE
          final firstSignalOrder = journey.first.order;
          when(mockTemporaryConstraint.startLocation).thenReturn(calculateOrderInverse(0, firstSignalOrder));
          when(mockTemporaryConstraint.endLocation).thenReturn(calculateOrderInverse(0, servicePoints[1].order) + 1);

          // ACT & EXPECT
          expect(
            testee.call(mockJourneyProfile, [mockSegmentProfile], journey),
            orderedEquals([
              VelocityMaxAdvisedSpeedSegment(
                startOrder: firstSignalOrder,
                endOrder: servicePoints[1].order,
                endData: servicePoints[1],
              ),
            ]),
          );
        });

        test('whenEndMidwayAdjacentSP_thenIsBetweenFirstSignalAndSecondSP', () {
          // ARRANGE
          final firstSignalOrder = journey.first.order;
          when(mockTemporaryConstraint.startLocation).thenReturn(calculateOrderInverse(0, firstSignalOrder));
          when(mockTemporaryConstraint.endLocation).thenReturn(2000);

          // ACT & EXPECT
          expect(
            testee.call(mockJourneyProfile, [mockSegmentProfile], journey),
            orderedEquals([
              VelocityMaxAdvisedSpeedSegment(
                startOrder: firstSignalOrder,
                endOrder: servicePoints[1].order,
                endData: servicePoints[1],
              ),
            ]),
          );
        });

        test('whenEndMidwayNonAdjacentSPs_thenIsBetweenFirstSignalAndLastSP', () {
          // ARRANGE
          final firstSignalOrder = journey.first.order;
          when(mockTemporaryConstraint.startLocation).thenReturn(calculateOrderInverse(0, firstSignalOrder));
          when(mockTemporaryConstraint.endLocation).thenReturn(4000.0);

          // ACT & EXPECT
          expect(
            testee.call(mockJourneyProfile, [mockSegmentProfile], journey),
            orderedEquals([
              VelocityMaxAdvisedSpeedSegment(
                startOrder: firstSignalOrder,
                endOrder: servicePoints.last.order,
                endData: servicePoints.last,
              ),
            ]),
          );
        });

        /// end is known on last service point
        test('whenStartCloseAdjacentSP_thenIsBetweenSecondSPAndLastSP', () {
          // ARRANGE
          when(mockTemporaryConstraint.startLocation).thenReturn(2999.0);
          when(mockTemporaryConstraint.endLocation).thenReturn(5000.0);

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

        test('whenStartCloseNonAdjacentSP_thenIsBetweenFirstSPAndLastSP', () {
          // ARRANGE
          when(mockTemporaryConstraint.startLocation).thenReturn(999.0);
          when(mockTemporaryConstraint.endLocation).thenReturn(5000.0);

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

        test('whenStartMidwayBetweenAdjacentSPs_thenIsBetweenSecondSPAndLastSP', () {
          // ARRANGE
          when(mockTemporaryConstraint.startLocation).thenReturn(4000.0);
          when(mockTemporaryConstraint.endLocation).thenReturn(5000.0);

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

        test('whenStartMidwayBetweenNonAdjacentSPs_thenIsBetweenFirstSPAndLastSP', () {
          // ARRANGE
          when(mockTemporaryConstraint.startLocation).thenReturn(2000.0);
          when(mockTemporaryConstraint.endLocation).thenReturn(5000.0);

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

        // one test for end not being on a SP
        test('whenEndOnLastSignalAndStartCloseSecondSP_thenIsBetweenSecondSPAndLastSignal', () {
          // ARRANGE
          final lastSignalOrder = journey.last.order;
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

        /// close to same service point
        test('whenStartFirstSPAndEndCloseFirstSP_thenIsSkipped', () {
          // ARRANGE
          final firstServicePointLocation = 1000.0;
          when(mockTemporaryConstraint.startLocation).thenReturn(firstServicePointLocation);
          when(mockTemporaryConstraint.endLocation).thenReturn(firstServicePointLocation + 10);

          // ACT & EXPECT
          expect(testee.call(mockJourneyProfile, [mockSegmentProfile], journey), isEmpty);
        });

        test('whenEndSecondSPAndStartCloseSecondSP_thenIsSkipped', () {
          // ARRANGE
          final midServicePoint = 3000.0;
          when(mockTemporaryConstraint.startLocation).thenReturn(midServicePoint - 10);
          when(mockTemporaryConstraint.endLocation).thenReturn(midServicePoint);

          // ACT & EXPECT
          expect(testee.call(mockJourneyProfile, [mockSegmentProfile], journey), isEmpty);
        });

        test('whenEndLastSPAndStartCloseLastSP_thenIsSkipped', () {
          // ARRANGE
          final lastServicePointLocation = 5000.0;
          when(mockTemporaryConstraint.startLocation).thenReturn(lastServicePointLocation - 10);
          when(mockTemporaryConstraint.endLocation).thenReturn(lastServicePointLocation);

          // ACT & EXPECT
          expect(testee.call(mockJourneyProfile, [mockSegmentProfile], journey), isEmpty);
        });
      });

      /// 1. Locations are close to the same service point (all three service points) --> They are skipped
      /// 2. Locations are close to different service points (pairs: 1 - 2, 2 - 3, 1 - 3)
      /// 3. Locations are midway between SPs (in different intervals, since they need to be absolutely different)
      group('Both locations unknown', () {
        /// Same Service point
        test('whenCloseFirstSP_thenIsSkipped', () {
          // ARRANGE
          when(mockTemporaryConstraint.startLocation).thenReturn(999.0);
          when(mockTemporaryConstraint.endLocation).thenReturn(1001.0);

          // ACT & EXPECT
          expect(testee.call(mockJourneyProfile, [mockSegmentProfile], journey), isEmpty);
        });

        test('whenCloseLastSP_thenIsSkipped', () {
          // ARRANGE
          when(mockTemporaryConstraint.startLocation).thenReturn(4999.0);
          when(mockTemporaryConstraint.endLocation).thenReturn(5001.0);

          // ACT & EXPECT
          expect(testee.call(mockJourneyProfile, [mockSegmentProfile], journey), isEmpty);
        });

        test('whenCloseToSecondSP_thenIsSkipped', () {
          // ARRANGE
          when(mockTemporaryConstraint.startLocation).thenReturn(2999.0);
          when(mockTemporaryConstraint.endLocation).thenReturn(3001.0);

          // ACT & EXPECT
          expect(testee.call(mockJourneyProfile, [mockSegmentProfile], journey), isEmpty);
        });

        /// Different Service points
        test('whenStartCloseToFirstSPAndEndCloseSecondSP_thenIsBetweenFirstSPAndSecondSP (1 - 2)', () {
          // ARRANGE
          when(mockTemporaryConstraint.startLocation).thenReturn(1001.0);
          when(mockTemporaryConstraint.endLocation).thenReturn(2999.0);

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

        test('whenStartCloseToSecondSPAndEndCloseSecondSP_thenIsBetweenSecondSPAndLastSP (2 - 3)', () {
          // ARRANGE
          when(mockTemporaryConstraint.startLocation).thenReturn(2999.0);
          when(mockTemporaryConstraint.endLocation).thenReturn(5001.0);

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

        test('whenStartCloseToFirstSPAndEndCloseLastSP_thenIsBetweenFirstSPAndLastSP (1 - 3)', () {
          // ARRANGE
          final servicePoints = journey.whereType<ServicePoint>().toList();
          when(
            mockTemporaryConstraint.startLocation,
          ).thenReturn(calculateOrderInverse(0, servicePoints.first.order) + 1);
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

        /// Midway Service points
        test('whenStartMidwayInBetweenFirstTwoAndEndMidwayInBetweenLatterTwo_thenIsBetweenFirstSPAndLastSP', () {
          // ARRANGE
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
      });
    });
  });
}

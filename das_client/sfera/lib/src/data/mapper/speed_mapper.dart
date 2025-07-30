import 'package:logging/logging.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/graduated_speed_info_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/jp_context_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/new_speed_nsp_dto.dart';
import 'package:sfera/src/data/dto/reason_code_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/velocity_dto.dart';
import 'package:sfera/src/data/mapper/mapper_utils.dart';

final _log = Logger('SpeedMapper');

/// Used to map data from SFERA to domain model speeds.
class SpeedMapper {
  SpeedMapper._();

  /// Maps list of SFERA model [VelocityDto] to [TrainSeriesSpeed]
  static List<TrainSeriesSpeed>? fromVelocities(Iterable<VelocityDto>? velocities) {
    if (velocities == null) return null;

    final result = <TrainSeriesSpeed>[];

    void addSpeed(TrainSeries trainSeries, int? breakSeries, String speedString, bool reduced) {
      try {
        final speeds = TrainSeriesSpeed(
          trainSeries: trainSeries,
          speed: Speed.parse(speedString),
          breakSeries: breakSeries,
          reduced: reduced,
        );
        result.add(speeds);
      } catch (e) {
        _log.warning('Could not parse speed with "$speedString"', e);
      }
    }

    for (final velocity in velocities) {
      if (velocity.speed != null) {
        addSpeed(velocity.trainSeries, velocity.brakeSeries, velocity.speed!, velocity.reduced);
      }
    }

    return result;
  }

  /// Maps SFERA model [GraduatedSpeedInfoDto] to [TrainSeriesSpeed]
  static List<TrainSeriesSpeed>? fromGraduatedSpeedInfo(GraduatedSpeedInfoDto? graduatedSpeedInfo) {
    if (graduatedSpeedInfo == null) return null;

    final result = <TrainSeriesSpeed>[];

    void addSpeed(TrainSeries trainSeries, String speedString, String? text) {
      try {
        final speeds = TrainSeriesSpeed(trainSeries: trainSeries, speed: Speed.parse(speedString), text: text);
        result.add(speeds);
      } catch (e) {
        _log.warning('Could not parse graduated station speed info with "$speedString"', e);
      }
    }

    for (final entity in graduatedSpeedInfo.entities) {
      if (entity.adSpeed != null) {
        addSpeed(TrainSeries.A, entity.adSpeed!, entity.text);
        addSpeed(TrainSeries.D, entity.adSpeed!, entity.text);
      }
      if (entity.nSpeed != null) {
        addSpeed(TrainSeries.N, entity.nSpeed!, entity.text);
      }
      if (entity.sSpeed != null) {
        addSpeed(TrainSeries.S, entity.sSpeed!, entity.text);
      }
      if (entity.roSpeed != null) {
        addSpeed(TrainSeries.R, entity.roSpeed!, entity.text);
        addSpeed(TrainSeries.O, entity.roSpeed!, entity.text);
      }
    }

    return result;
  }

  static SingleSpeed? fromJourneyProfileContextInfoNsp(JpContextInformationNspDto? jpContextInfoNsp) {
    if (jpContextInfoNsp == null) return null;

    final nsp = jpContextInfoNsp.parameters.firstOrNull;
    if (nsp is! NewSpeedNetworkSpecificParameterDto) return null;

    return SingleSpeed(value: nsp.speed);
  }

  static Iterable<AdvisedSpeedSegment> advisedSpeeds(
    JourneyProfileDto journeyProfile,
    List<SegmentProfileDto> segmentProfiles,
    List<BaseData> journeyData,
  ) {
    final List<AdvisedSpeedSegment> result = [];
    final segmentProfileReferences = journeyProfile.segmentProfileReferences.toList();

    for (int segmentIndex = 0; segmentIndex < segmentProfileReferences.length; segmentIndex++) {
      final segmentProfileReference = segmentProfileReferences[segmentIndex];
      final segmentProfile = segmentProfiles.where((sP) => sP.id == segmentProfileReference.spId).first;

      for (final speedConstraint in segmentProfileReference.advisedSpeedTemporaryConstraints) {
        if (speedConstraint.advisedSpeed == null) {
          _log.warning('AdvisedSpeedTemporaryConstraint found with no advised speeds.');
          continue;
        }

        final journeyOrders = journeyData.map((it) => it.order);
        final servicePoints = journeyData.whereType<ServicePoint>();

        int startOrder = calculateOrder(segmentIndex, speedConstraint.startLocation ?? 0);
        if (!journeyOrders.contains(startOrder)) {
          startOrder = _orderFromClosestServicePoint(startOrder, servicePoints) ?? 0;
        }
        int endOrder = calculateOrder(segmentIndex, speedConstraint.endLocation ?? double.parse(segmentProfile.length));
        if (!journeyOrders.contains(endOrder)) {
          // reversed since the advised speed segment should be as big as possible if two closest service points
          endOrder = _orderFromClosestServicePoint(endOrder, servicePoints.toList().reversed) ?? 0;
        }

        final endData = journeyData.where((it) => it.order == endOrder).first;

        final advisedSpeed = speedConstraint.advisedSpeed!;
        SingleSpeed? speed;
        if (advisedSpeed.speed != null) speed = Speed.parse(advisedSpeed.speed!) as SingleSpeed;

        if (speed == null && advisedSpeed.deltaSpeed == null) {
          _log.warning('AdvisedSpeed found with no speed and no deltaSpeed. Skipping');
          continue;
        }

        if (speed == null) {
          result.add(VelocityMaxAdvisedSpeedSegment(startOrder: startOrder, endOrder: endOrder, endData: endData));
        } else {
          switch (advisedSpeed.reasonCode) {
            case ReasonCodeDto.followTrain:
              result.add(
                FollowTrainAdvisedSpeedSegment(
                  startOrder: startOrder,
                  endOrder: endOrder,
                  speed: speed,
                  endData: endData,
                ),
              );
              break;
            case ReasonCodeDto.trainFollowing:
              result.add(
                TrainFollowingAdvisedSpeedSegment(
                  startOrder: startOrder,
                  endOrder: endOrder,
                  speed: speed,
                  endData: endData,
                ),
              );
              break;
            case ReasonCodeDto.adlFixedTime:
              result.add(
                FixedTimeAdvisedSpeedSegment(
                  startOrder: startOrder,
                  endOrder: endOrder,
                  speed: speed,
                  endData: endData,
                ),
              );
              break;
            default:
              _log.warning('Skipping AdvisedSpeed found with reasonCode that cannot be handled: $advisedSpeed');
              continue;
          }
        }
      }
    }

    return result;
  }

  static int? _orderFromClosestServicePoint(int order, Iterable<ServicePoint> servicePoints) {
    ServicePoint? champion;
    int minDistance = double.maxFinite.toInt();
    for (final sP in servicePoints) {
      final currentDistance = (sP.order - order).abs();
      if (currentDistance < minDistance) {
        champion = sP;
        minDistance = currentDistance;
      }
    }
    return champion?.order;
  }
}

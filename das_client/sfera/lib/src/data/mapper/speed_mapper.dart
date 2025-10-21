import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/graduated_speed_info_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/jp_context_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/new_speed_nsp_dto.dart';
import 'package:sfera/src/data/dto/reason_code_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/temporary_constraints_dto.dart';
import 'package:sfera/src/data/dto/velocity_dto.dart';
import 'package:sfera/src/data/mapper/draft_advised_speed_segment.dart';
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

  /// Parse advised speed segments.
  ///
  /// O(n)
  ///
  /// Skips invalid speed segments (e.g. endLocation before startLocation or startLocation == endLocation)
  ///
  /// 1. iteration parses all as DraftAdvisedSpeedSegments
  /// 2. try to merge DraftAdvisedSpeedSegments and skip open segments
  /// 3. segments with unknown locations are mapped to the closest service points
  static Iterable<AdvisedSpeedSegment> advisedSpeeds(
    JourneyProfileDto journeyProfile,
    List<SegmentProfileDto> segmentProfiles,
    List<BaseData> journeyData,
  ) {
    final drafts = _parseAllSegmentsToDrafts(journeyProfile, segmentProfiles);
    final List<DraftAdvisedSpeedSegment> mergedDrafts = _mergeAdvisedSegments(drafts);
    final result = _mapUnknownLocationsToClosestServicePoints(mergedDrafts, journeyData);

    return result;
  }

  static List<DraftAdvisedSpeedSegment> _parseAllSegmentsToDrafts(
    JourneyProfileDto journeyProfile,
    List<SegmentProfileDto> segmentProfiles,
  ) {
    final segmentProfileReferences = journeyProfile.segmentProfileReferences.toList();
    final List<DraftAdvisedSpeedSegment> drafts = [];
    int previousSegmentEndOrder = 0;
    int nextSegmentStartOrder = 0;

    for (int segmentIndex = 0; segmentIndex < segmentProfileReferences.length; segmentIndex++) {
      final segmentProfileReference = segmentProfileReferences[segmentIndex];
      final segmentProfile = segmentProfiles.firstWhere((sP) => sP.id == segmentProfileReference.spId);

      nextSegmentStartOrder = segmentIndex + 1 < segmentProfileReferences.length
          ? calculateOrder(segmentIndex + 1, 0)
          : calculateOrder(segmentIndex, segmentProfile.length);

      for (final speedConstraint in segmentProfileReference.advisedSpeedTemporaryConstraints) {
        if (_invalidAdvisedSpeed(speedConstraint)) continue;

        final draft = _mapToDraftAdvisedSpeedSegment(
          speedConstraint,
          segmentIndex,
          nextSegmentStartOrder,
          previousSegmentEndOrder,
        );

        if (draft != null) drafts.add(draft);
      }
      previousSegmentEndOrder = calculateOrder(segmentIndex, segmentProfile.length);
    }
    return drafts;
  }

  static DraftAdvisedSpeedSegment? _mapToDraftAdvisedSpeedSegment(
    TemporaryConstraintsDto speedConstraint,
    int segmentIndex,
    int nextSegmentStartOrder,
    int previousSegmentEndOrder,
  ) {
    final startOrder = speedConstraint.startLocation != null
        ? calculateOrder(segmentIndex, speedConstraint.startLocation!)
        : null;
    final endOrder = speedConstraint.endLocation != null
        ? calculateOrder(segmentIndex, speedConstraint.endLocation!)
        : null;

    final advisedSpeed = speedConstraint.advisedSpeed!;
    SingleSpeed? speed;
    if (advisedSpeed.speed != null) speed = Speed.parse(advisedSpeed.speed!) as SingleSpeed;

    DraftAdvisedSpeedType? segmentType;

    if (speed == null) {
      segmentType = DraftAdvisedSpeedType.velocityMax;
    } else {
      switch (advisedSpeed.reasonCode) {
        case ReasonCodeDto.followTrain:
          segmentType = DraftAdvisedSpeedType.followTrain;
        case ReasonCodeDto.trainFollowing:
          segmentType = DraftAdvisedSpeedType.trainFollowing;
        case ReasonCodeDto.advisedSpeedFixedTime:
          segmentType = DraftAdvisedSpeedType.fixedTime;
        default:
          _log.warning('Skipping AdvisedSpeed found with reasonCode that cannot be handled: $advisedSpeed');
      }
    }
    if (segmentType == null) return null;

    final result = DraftAdvisedSpeedSegment(
      nextSegmentStartOrder: nextSegmentStartOrder,
      previousSegmentEndOrder: previousSegmentEndOrder,
      type: segmentType,
      speed: speed,
      startOrder: startOrder,
      endOrder: endOrder,
    );
    return result;
  }

  static List<DraftAdvisedSpeedSegment> _mergeAdvisedSegments(List<DraftAdvisedSpeedSegment> drafts) {
    final groupedAdvisedSpeedSegments = drafts.groupListsBy((draft) => draft.advisedSpeedGroupKey);

    groupedAdvisedSpeedSegments.updateAll((key, drafts) {
      drafts.sort();
      final mergedDrafts = <DraftAdvisedSpeedSegment>[];

      DraftAdvisedSpeedSegment currentDraft = drafts.first;

      int idx = 1;
      while (idx <= drafts.length) {
        if (idx == drafts.length) {
          mergedDrafts.add(currentDraft);
          break;
        }
        final nextDraft = drafts[idx];
        if (currentDraft.endOrder >= nextDraft.startOrder) {
          currentDraft = currentDraft.merge(nextDraft);
        } else {
          mergedDrafts.add(currentDraft);
          currentDraft = nextDraft;
        }

        idx++;
      }

      return _filterOpenSegments(mergedDrafts);
    });

    return groupedAdvisedSpeedSegments.values.flattened.toList(growable: false).sorted();
  }

  static List<AdvisedSpeedSegment> _mapUnknownLocationsToClosestServicePoints(
    List<DraftAdvisedSpeedSegment> mergedDrafts,
    List<BaseData> journeyData,
  ) {
    final journeyOrders = journeyData.map((d) => d.order);
    final servicePoints = journeyData.whereType<ServicePoint>().where((sP) => !sP.isAdditional);

    final result = <AdvisedSpeedSegment>[];
    for (int idx = 0; idx < mergedDrafts.length; idx++) {
      final draft = mergedDrafts[idx];

      final startUnknown = (!journeyOrders.contains(draft.startOrder) || draft.startsWithSegment);
      final endUnknown = (!journeyOrders.contains(draft.endOrder) || draft.endsWithSegment);

      if (startUnknown) {
        draft.startOrder = _orderFromClosestServicePoint(draft.startOrder, servicePoints) ?? draft.endOrder;
      }
      if (endUnknown) {
        draft.endOrder = _orderFromClosestServicePoint(draft.endOrder, servicePoints.toList().reversed) ?? 0;
      }

      if (draft.isValid) {
        draft.endData = journeyData.firstWhere((it) => it.order == draft.endOrder);
        result.add(draft.toAdvisedSegment());
      }
    }
    return result;
  }

  static List<DraftAdvisedSpeedSegment> _filterOpenSegments(List<DraftAdvisedSpeedSegment> mergedDrafts) {
    final result = mergedDrafts.whereNot((d) => d.startsWithSegment || d.endsWithSegment).toList();
    if (result.length != mergedDrafts.length) {
      final openSegments = mergedDrafts.where((d) => d.startsWithSegment || d.endsWithSegment).toList();
      _log.warning('Advised Speed Segments found that could not be closed. Skipping: $openSegments');
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

  static bool _invalidAdvisedSpeed(TemporaryConstraintsDto speedConstraint) {
    if (speedConstraint.advisedSpeed == null) {
      _log.warning('AdvisedSpeedTemporaryConstraint found with no advised speeds. Skipping');
      return true;
    }
    if (speedConstraint.advisedSpeed?.speed == null && speedConstraint.advisedSpeed?.deltaSpeed == null) {
      _log.warning('AdvisedSpeedTemporaryConstraint found with no speed and no deltaSpeed. Skipping');
      return true;
    }
    final hasStartOrEnd = speedConstraint.startLocation != null || speedConstraint.endLocation != null;
    if (hasStartOrEnd && speedConstraint.startLocation == speedConstraint.endLocation) {
      _log.warning('AdvisedSpeedTemporaryConstraint found with same start and end location. Skipping.');
      return true;
    }
    final hasStartAndEnd = speedConstraint.startLocation != null && speedConstraint.endLocation != null;
    if (hasStartAndEnd && (speedConstraint.startLocation! > speedConstraint.endLocation!)) {
      _log.warning('AdvisedSpeedTemporaryConstraint found with end before start location. Skipping.');
      return true;
    }
    if (!hasStartAndEnd) {
      _log.info(
        'AdvisedSpeedTemporaryConstraint found without start and end location. Will map onto first and last service point of Segment Profile!',
      );
      return false;
    }
    if (!hasStartOrEnd) {
      _log.info(
        'AdvisedSpeedTemporaryConstraint found without start or end location. Will map to a service point!',
      );
    }

    return false;
  }
}

import 'dart:math';

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
  ///
  ///
  /// O(n<sup>2</sup>)
  ///
  /// if start / end is null (or wholeSP => start == null && end == null), set mergeLocationStart and -end to next SegmentStart / previousSegmentEnd
  /// calculate hashCode of type & speed & "group"
  /// sort group by mergeLocationStart
  /// iterate through and compare end nth to start nth + 1
  /// merge if overlap
  ///
  /// do the whole unknown locations thing and set flag if unknown location mapped
  ///
  /// iterate through again
  /// warn / error if multiple adl in same part of the journey
  /// shrink mapped segments if hits a non mapped segment
  static Iterable<AdvisedSpeedSegment> advisedSpeeds(
    JourneyProfileDto journeyProfile,
    List<SegmentProfileDto> segmentProfiles,
    List<BaseData> journeyData,
  ) {
    final segmentProfileReferences = journeyProfile.segmentProfileReferences.toList();

    final List<DraftAdvisedSpeedSegment> drafts = [];

    final journeyOrders = journeyData.map((it) => it.order);
    final servicePoints = journeyData.whereType<ServicePoint>().whereNot((sp) => sp.isAdditional);

    int previousSegmentEndOrder = 0;
    int nextSegmentStartOrder = 0;

    for (int segmentIndex = 0; segmentIndex < segmentProfileReferences.length; segmentIndex++) {
      final segmentProfileReference = segmentProfileReferences[segmentIndex];
      final segmentProfile = segmentProfiles.firstWhere((sP) => sP.id == segmentProfileReference.spId);

      nextSegmentStartOrder = segmentIndex + 1 < segmentProfileReferences.length
          ? calculateOrder(segmentIndex + 1, 0)
          : calculateOrder(segmentIndex, double.parse(segmentProfile.length));

      for (final speedConstraint in segmentProfileReference.advisedSpeedTemporaryConstraints) {
        if (_invalidAdvisedSpeed(speedConstraint)) continue;

        final startOrder = speedConstraint.startLocation != null
            ? calculateOrder(segmentIndex, speedConstraint.startLocation!)
            : null;
        final endOrder = speedConstraint.endLocation != null
            ? calculateOrder(segmentIndex, speedConstraint.endLocation!)
            : null;

        final advisedSpeed = speedConstraint.advisedSpeed!;
        SingleSpeed? speed;
        if (advisedSpeed.speed != null) speed = Speed.parse(advisedSpeed.speed!) as SingleSpeed;

        if (speed == null) {
          drafts.add(
            DraftAdvisedSpeedSegment(
              nextSegmentStartOrder: nextSegmentStartOrder,
              previousSegmentEndOrder: previousSegmentEndOrder,
              type: DraftAdvisedSpeedType.velocityMax,
              startOrder: startOrder,
              endOrder: endOrder,
            ),
          );
          continue;
        }
        switch (advisedSpeed.reasonCode) {
          case ReasonCodeDto.followTrain:
            drafts.add(
              DraftAdvisedSpeedSegment(
                nextSegmentStartOrder: nextSegmentStartOrder,
                previousSegmentEndOrder: previousSegmentEndOrder,
                type: DraftAdvisedSpeedType.followTrain,
                speed: speed,
                startOrder: startOrder,
                endOrder: endOrder,
              ),
            );
            break;
          case ReasonCodeDto.trainFollowing:
            drafts.add(
              DraftAdvisedSpeedSegment(
                nextSegmentStartOrder: nextSegmentStartOrder,
                previousSegmentEndOrder: previousSegmentEndOrder,
                type: DraftAdvisedSpeedType.trainFollowing,
                speed: speed,
                startOrder: startOrder,
                endOrder: endOrder,
              ),
            );
            break;
          case ReasonCodeDto.AdvisedSpeedFixedTime:
            drafts.add(
              DraftAdvisedSpeedSegment(
                nextSegmentStartOrder: nextSegmentStartOrder,
                previousSegmentEndOrder: previousSegmentEndOrder,
                type: DraftAdvisedSpeedType.fixedTime,
                speed: speed,
                startOrder: startOrder,
                endOrder: endOrder,
              ),
            );
            break;
          default:
            _log.warning('Skipping AdvisedSpeed found with reasonCode that cannot be handled: $advisedSpeed');
            continue;
        }
      }
      previousSegmentEndOrder = calculateOrder(segmentIndex, double.parse(segmentProfile.length));
    }

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

    final List<DraftAdvisedSpeedSegment> allDrafts = groupedAdvisedSpeedSegments.values.flattened
        .toList(growable: false)
        .sorted();

    final result = <AdvisedSpeedSegment>[];
    for (int idx = 0; idx < allDrafts.length; idx++) {
      final draft = allDrafts[idx];

      final startUnknown = (!journeyOrders.contains(draft.startOrder) || draft.startsWithSegment);
      final endUnknown = (!journeyOrders.contains(draft.endOrder) || draft.endsWithSegment);

      if (startUnknown) {
        draft.startOrder = _orderFromClosestServicePoint(draft.startOrder, servicePoints) ?? draft.endOrder;
      }
      if (endUnknown) {
        draft.endOrder = _orderFromClosestServicePoint(draft.endOrder, servicePoints.toList().reversed) ?? 0;
      }

      if (draft.endOrder > draft.startOrder && draft.endsWithSegment == false && draft.startsWithSegment == false) {
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

class DraftAdvisedSpeedSegment implements Comparable<DraftAdvisedSpeedSegment> {
  DraftAdvisedSpeedSegment({
    required this.type,
    required int previousSegmentEndOrder,
    required int nextSegmentStartOrder,
    this.speed,
    int? startOrder,
    int? endOrder,
  }) : _startOrder = startOrder,
       _endOrder = endOrder,
       _nextSegmentStartOrder = nextSegmentStartOrder,
       _previousSegmentEndOrder = previousSegmentEndOrder;

  int? _startOrder;
  int? _endOrder;

  final int _previousSegmentEndOrder;
  final int _nextSegmentStartOrder;

  final DraftAdvisedSpeedType type;

  final SingleSpeed? speed;

  bool _isStartAmended = false;
  bool _isEndAmended = false;

  bool get startsWithSegment => _startOrder == null;

  bool get endsWithSegment => _endOrder == null;

  bool get isStartAmended => _isStartAmended;

  bool get isEndAmended => _isEndAmended;

  BaseData? endData;

  set startOrder(int value) {
    _startOrder = value;
    _isStartAmended = true;
  }

  set endOrder(int value) {
    _endOrder = value;
    _isEndAmended = true;
  }

  int get startOrder => _startOrder ?? _previousSegmentEndOrder;

  int get endOrder => _endOrder ?? _nextSegmentStartOrder;

  int get advisedSpeedGroupKey => Object.hash(speed, type);

  @override
  String toString() =>
      'DraftAdvisedSpeedSegment: ('
      'type: $type'
      ', previousSegmentEndOrder: $_previousSegmentEndOrder'
      ', nextSegmentStartOrder: $_nextSegmentStartOrder'
      ', speed: $speed'
      ', startOrder: $_startOrder'
      ', endOrder: $_endOrder'
      ', isStartAmended: $isStartAmended'
      ', isEndAmended: $isEndAmended'
      ')';

  @override
  int compareTo(DraftAdvisedSpeedSegment other) => startOrder.compareTo(other.startOrder);

  DraftAdvisedSpeedSegment merge(DraftAdvisedSpeedSegment other) {
    return DraftAdvisedSpeedSegment(
      type: type,
      previousSegmentEndOrder: min(_previousSegmentEndOrder, other._previousSegmentEndOrder),
      nextSegmentStartOrder: max(_nextSegmentStartOrder, other._nextSegmentStartOrder),
      speed: speed,
      startOrder: _mergeOrder(_startOrder, other._startOrder, min),
      endOrder: _mergeOrder(_endOrder, other._endOrder, max),
    );
  }

  int? _mergeOrder(int? order, int? otherOrder, T Function<T extends num>(T a, T b) func) {
    if (order != null && otherOrder != null) return func(order, otherOrder);
    if (order == null && otherOrder == null) return null;
    return order ?? otherOrder;
  }

  AdvisedSpeedSegment toAdvisedSegment() {
    if (endData == null) throw FormatException('Cannot map to advisedSegment without having endData set!');
    return switch (type) {
      DraftAdvisedSpeedType.velocityMax => VelocityMaxAdvisedSpeedSegment(
        startOrder: startOrder,
        endOrder: endOrder,
        endData: endData!,
      ),
      DraftAdvisedSpeedType.followTrain => FollowTrainAdvisedSpeedSegment(
        startOrder: startOrder,
        endOrder: endOrder,
        speed: speed!,
        endData: endData!,
      ),
      DraftAdvisedSpeedType.trainFollowing => TrainFollowingAdvisedSpeedSegment(
        startOrder: startOrder,
        endOrder: endOrder,
        speed: speed!,
        endData: endData!,
      ),
      DraftAdvisedSpeedType.fixedTime => FixedTimeAdvisedSpeedSegment(
        startOrder: startOrder,
        endOrder: endOrder,
        speed: speed!,
        endData: endData!,
      ),
    };
  }
}

enum DraftAdvisedSpeedType {
  velocityMax,
  followTrain,
  trainFollowing,
  fixedTime,
}

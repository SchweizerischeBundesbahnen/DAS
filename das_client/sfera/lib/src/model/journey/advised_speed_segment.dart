import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:sfera/component.dart';

enum AdvisedSpeedSegmentHint {
  servicePointWithLocalSpeed,
  curvePointWithLocalSpeed,
  additionalSpeedRestriction,
}

sealed class const AdvisedSpeedSegment({
  required super.startOrder,
  required super.endOrder,
  required final BaseData endData,

  /// If the end location was unknown and mapped to the closest [JourneyPoint], this will be true.
  final bool isEndDataCalculated = false,

  /// Additional hints depending on journey points within the advised speed segment.
  final Set<AdvisedSpeedSegmentHint> additionalHints = const <AdvisedSpeedSegmentHint>{},
}) extends Segment {
  SingleSpeed? get speed => switch (this) {
    final FollowTrainAdvisedSpeedSegment aS => aS.speed,
    final TrainFollowingAdvisedSpeedSegment aS => aS.speed,
    final FixedTimeAdvisedSpeedSegment aS => aS.speed,
    final VelocityMaxAdvisedSpeedSegment _ => null,
  };

  /// TMS VAD delivers Advised Speed Notifications to signal keeping distance with a optimalSpeed of `0`
  ///
  /// Planned to be removed in Release 2 of DAS Client.
  bool get isDIST => speed != null && speed!.value == '0';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AdvisedSpeedSegment &&
            startOrder == other.startOrder &&
            endOrder == other.endOrder &&
            endData == other.endData &&
            isEndDataCalculated == other.isEndDataCalculated &&
            SetEquality().equals(additionalHints, other.additionalHints);
  }

  @override
  int get hashCode => Object.hash(startOrder, endOrder, endData, isEndDataCalculated, additionalHints);

  @override
  String toString() {
    return 'AdvisedSpeedSegment{'
        'startOrder: $startOrder'
        ', endOrder: $endOrder'
        ', speed: $speed'
        ', endData: $endData'
        ', isEndDataCalculated: $isEndDataCalculated'
        ', additionalHints: $additionalHints'
        '}';
  }
}

class FollowTrainAdvisedSpeedSegment extends AdvisedSpeedSegment {
  const FollowTrainAdvisedSpeedSegment({
    required super.startOrder,
    required super.endOrder,
    required super.endData,
    required this.speed,
    super.isEndDataCalculated,
    super.additionalHints,
  });

  @override
  final SingleSpeed speed;

  @override
  bool operator ==(Object other) => super == other && other is FollowTrainAdvisedSpeedSegment && other.speed == speed;

  @override
  int get hashCode => Object.hash(super.hashCode, speed);
}

class TrainFollowingAdvisedSpeedSegment extends AdvisedSpeedSegment {
  const TrainFollowingAdvisedSpeedSegment({
    required super.startOrder,
    required super.endOrder,
    required super.endData,
    required this.speed,
    super.isEndDataCalculated,
    super.additionalHints,
  });

  @override
  final SingleSpeed speed;

  @override
  bool operator ==(Object other) =>
      super == other && other is TrainFollowingAdvisedSpeedSegment && other.speed == speed;

  @override
  int get hashCode => Object.hash(super.hashCode, speed);
}

class FixedTimeAdvisedSpeedSegment extends AdvisedSpeedSegment {
  const FixedTimeAdvisedSpeedSegment({
    required super.startOrder,
    required super.endOrder,
    required super.endData,
    required this.speed,
    super.isEndDataCalculated,
    super.additionalHints,
  });

  @override
  final SingleSpeed speed;

  @override
  bool operator ==(Object other) => super == other && other is FixedTimeAdvisedSpeedSegment && other.speed == speed;

  @override
  int get hashCode => Object.hash(super.hashCode, speed);
}

/// If deltaSpeed equal to zero is provided, train driver should drive as fast as possible.
class VelocityMaxAdvisedSpeedSegment extends AdvisedSpeedSegment {
  const VelocityMaxAdvisedSpeedSegment({
    required super.startOrder,
    required super.endOrder,
    required super.endData,
    super.isEndDataCalculated,
    super.additionalHints,
  });
}

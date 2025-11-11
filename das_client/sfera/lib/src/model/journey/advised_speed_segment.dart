import 'package:sfera/component.dart';

sealed class AdvisedSpeedSegment extends Segment {
  const AdvisedSpeedSegment({
    required int startOrder,
    required int endOrder,
    required this.endData,
    this.isEndDataCalculated = false,
  }) : super(startOrder: startOrder, endOrder: endOrder);

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

  final BaseData endData;

  /// If the end location was unknown and mapped to the closest [JourneyPoint], this will be true.
  final bool isEndDataCalculated;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AdvisedSpeedSegment &&
            startOrder == other.startOrder &&
            endOrder == other.endOrder &&
            endData == other.endData &&
            isEndDataCalculated == other.isEndDataCalculated;
  }

  @override
  int get hashCode => Object.hash(startOrder, endOrder, endData, isEndDataCalculated);

  @override
  String toString() {
    return 'AdvisedSpeedSegment{'
        'startOrder: $startOrder'
        ', endOrder: $endOrder'
        ', speed: $speed'
        ', endData: $endData'
        ', isEndDataCalculated: $isEndDataCalculated'
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
  });

  @override
  final SingleSpeed speed;

  @override
  bool operator ==(Object other) => super == other || other is FollowTrainAdvisedSpeedSegment && other.speed == speed;

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
  });

  @override
  final SingleSpeed speed;

  @override
  bool operator ==(Object other) => super == other || other is FixedTimeAdvisedSpeedSegment && other.speed == speed;

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
  });
}

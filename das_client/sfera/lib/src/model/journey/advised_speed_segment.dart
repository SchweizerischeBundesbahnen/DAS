import 'package:sfera/component.dart';

sealed class AdvisedSpeedSegment extends Segment {
  const AdvisedSpeedSegment({
    required int startOrder,
    required int endOrder,
  }) : super(startOrder: startOrder, endOrder: endOrder);

  SingleSpeed? get speed => switch (this) {
    final FollowTrainAdvisedSpeedSegment aS => aS.speed,
    final TrainFollowingAdvisedSpeedSegment aS => aS.speed,
    final FixedTimeAdvisedSpeedSegment aS => aS.speed,
    final VelocityMaxAdvisedSpeedSegment _ => null,
  };

  @override
  String toString() {
    return '$runtimeType(startOrder: $startOrder, endOrder: $endOrder, speed: $speed)';
  }
}

class FollowTrainAdvisedSpeedSegment extends AdvisedSpeedSegment {
  const FollowTrainAdvisedSpeedSegment({
    required super.startOrder,
    required super.endOrder,
    required this.speed,
  });

  @override
  final SingleSpeed speed;
}

class TrainFollowingAdvisedSpeedSegment extends AdvisedSpeedSegment {
  const TrainFollowingAdvisedSpeedSegment({
    required super.startOrder,
    required super.endOrder,
    required this.speed,
  });

  @override
  final SingleSpeed speed;
}

class FixedTimeAdvisedSpeedSegment extends AdvisedSpeedSegment {
  const FixedTimeAdvisedSpeedSegment({
    required super.startOrder,
    required super.endOrder,
    required this.speed,
  });

  @override
  final SingleSpeed speed;
}

/// If deltaSpeed equal to zero is provided, train driver should drive as fast as possible.
class VelocityMaxAdvisedSpeedSegment extends AdvisedSpeedSegment {
  const VelocityMaxAdvisedSpeedSegment({
    required super.startOrder,
    required super.endOrder,
  });
}

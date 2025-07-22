import 'package:sfera/component.dart';

class AdvisedSpeedSegment extends Segment {
  const AdvisedSpeedSegment({
    super.startOrder,
    super.endOrder,
    this.speed,
    this.isActive = false,
  });

  final SingleSpeed? speed;

  /// whether the currentPosition is within this segment
  final bool isActive;
}

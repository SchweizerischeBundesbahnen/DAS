import 'package:sfera/component.dart';

class AdvisedSpeedSegment extends Segment {
  const AdvisedSpeedSegment({
    required this.speed,
    required final int startOrder,
    required final int endOrder,
    this.isActive = false,
  }) : super(startOrder: startOrder, endOrder: endOrder);

  final SingleSpeed speed;

  /// whether the currentPosition is within this segment
  final bool isActive;
}

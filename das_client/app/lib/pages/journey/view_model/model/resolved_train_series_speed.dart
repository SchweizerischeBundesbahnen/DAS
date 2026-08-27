import 'package:sfera/component.dart';

class ResolvedTrainSeriesSpeed({
  required final TrainSeriesSpeed? speed,
  required final bool isPrevious,
}) {
  factory ResolvedTrainSeriesSpeed.none() {
    return ResolvedTrainSeriesSpeed(
      speed: null,
      isPrevious: false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResolvedTrainSeriesSpeed &&
          runtimeType == other.runtimeType &&
          speed == other.speed &&
          isPrevious == other.isPrevious;

  @override
  int get hashCode => Object.hash(speed, isPrevious);

  @override
  String toString() {
    return 'ResolvedTrainSeriesSpeed{speed: $speed, isPrevious: $isPrevious}';
  }
}

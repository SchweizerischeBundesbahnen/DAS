import 'package:sfera/component.dart';

class ResolvedTrainSeriesSpeed {
  ResolvedTrainSeriesSpeed({
    required this.speed,
    required this.isPrevious,
  });

  factory ResolvedTrainSeriesSpeed.none() {
    return ResolvedTrainSeriesSpeed(
      speed: null,
      isPrevious: false,
    );
  }

  final TrainSeriesSpeed? speed;
  final bool isPrevious;
}

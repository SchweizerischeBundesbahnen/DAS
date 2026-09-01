import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sfera/src/model/journey/speed.dart';
import 'package:sfera/src/model/journey/train_series.dart';

/// Decorator class for [Speed] to enrich with TrainSeries and optional other information.
@sealed
@immutable
class const TrainSeriesSpeed({
  required final TrainSeries trainSeries,
  required final Speed speed,
  final int? brakedWeightPercentage,
  final String? text,
  final bool reduced = false,
}) {
  @override
  String toString() {
    return 'TrainSeriesSpeed{'
        'trainSeries: $trainSeries'
        ', speed: $speed'
        ', brakedWeightPercentage: $brakedWeightPercentage'
        ', text: $text'
        ', reduced: $reduced'
        '}';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TrainSeriesSpeed &&
            trainSeries == other.trainSeries &&
            speed == other.speed &&
            brakedWeightPercentage == other.brakedWeightPercentage &&
            text == other.text &&
            reduced == other.reduced);
  }

  @override
  int get hashCode => Object.hash(trainSeries, speed, brakedWeightPercentage, text, reduced);
}

extension TrainSeriesSpeedExtension on Iterable<TrainSeriesSpeed>? {
  TrainSeriesSpeed? speedFor(TrainSeries? trainSeries, {int? brakedWeightPercentage}) {
    if (trainSeries == null) return null;
    if (this == null) return null;

    final trainSeriesSpeeds = this!.where((it) => it.trainSeries == trainSeries);
    final exactMatchingVelocity = trainSeriesSpeeds.firstWhereOrNull(
      (it) => it.brakedWeightPercentage == brakedWeightPercentage,
    );
    return exactMatchingVelocity ?? trainSeriesSpeeds.firstWhereOrNull((it) => it.brakedWeightPercentage == null);
  }
}

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sfera/src/model/journey/speed.dart';
import 'package:sfera/src/model/journey/train_series.dart';

/// Decorator class for [Speed] to enrich with TrainSeries and optional other information.
@sealed
@immutable
class TrainSeriesSpeed {
  const TrainSeriesSpeed({
    required this.trainSeries,
    required this.speed,
    this.breakSeries,
    this.text,
    this.reduced = false,
  });

  final TrainSeries trainSeries;
  final Speed speed;
  final int? breakSeries;
  final String? text;
  final bool reduced;

  @override
  String toString() =>
      'TrainSeriesSpeed('
      'trainSeries: $trainSeries, '
      'speed: $speed, '
      'breakSeries: $breakSeries, '
      'text: $text, '
      'reduced: $reduced'
      ')';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TrainSeriesSpeed &&
            trainSeries == other.trainSeries &&
            speed == other.speed &&
            breakSeries == other.breakSeries &&
            text == other.text &&
            reduced == other.reduced);
  }

  @override
  int get hashCode => Object.hash(trainSeries, speed, breakSeries, text, reduced);
}

extension TrainSeriesSpeedExtension on Iterable<TrainSeriesSpeed>? {
  TrainSeriesSpeed? speedFor(TrainSeries? trainSeries, {int? breakSeries}) {
    if (trainSeries == null) return null;
    if (this == null) return null;

    final trainSeriesSpeeds = this!.where((it) => it.trainSeries == trainSeries);
    final exactMatchingVelocity = trainSeriesSpeeds.firstWhereOrNull((it) => it.breakSeries == breakSeries);
    return exactMatchingVelocity ?? trainSeriesSpeeds.firstWhereOrNull((it) => it.breakSeries == null);
  }
}

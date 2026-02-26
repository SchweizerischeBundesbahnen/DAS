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
    this.brakeSeries,
    this.text,
    this.reduced = false,
  });

  final TrainSeries trainSeries;
  final Speed speed;
  final int? brakeSeries;
  final String? text;
  final bool reduced;

  @override
  String toString() {
    return 'TrainSeriesSpeed{trainSeries: $trainSeries, speed: $speed, brakeSeries: $brakeSeries, text: $text, reduced: $reduced}';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TrainSeriesSpeed &&
            trainSeries == other.trainSeries &&
            speed == other.speed &&
            brakeSeries == other.brakeSeries &&
            text == other.text &&
            reduced == other.reduced);
  }

  @override
  int get hashCode => Object.hash(trainSeries, speed, brakeSeries, text, reduced);
}

extension TrainSeriesSpeedExtension on Iterable<TrainSeriesSpeed>? {
  TrainSeriesSpeed? speedFor(TrainSeries? trainSeries, {int? brakeSeries}) {
    if (trainSeries == null) return null;
    if (this == null) return null;

    final trainSeriesSpeeds = this!.where((it) => it.trainSeries == trainSeries);
    final exactMatchingVelocity = trainSeriesSpeeds.firstWhereOrNull((it) => it.brakeSeries == brakeSeries);
    return exactMatchingVelocity ?? trainSeriesSpeeds.firstWhereOrNull((it) => it.brakeSeries == null);
  }
}

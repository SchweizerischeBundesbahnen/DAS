import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sfera/src/model/journey/train_series.dart';
import 'package:sfera/src/model/journey/train_series_speed.dart';

@sealed
@immutable
class SpeedData {
  const SpeedData({this.speeds = const []});

  final List<TrainSeriesSpeed> speeds;

  TrainSeriesSpeed? speedsFor(TrainSeries? trainSeries, int? breakSeries) {
    if (trainSeries == null) return null;

    final trainSeriesSpeeds = speeds.where((it) => it.trainSeries == trainSeries);
    final exactMatchingVelocity = trainSeriesSpeeds.firstWhereOrNull((it) => it.breakSeries == breakSeries);
    return exactMatchingVelocity ?? trainSeriesSpeeds.firstWhereOrNull((it) => it.breakSeries == null);
  }

  @override
  String toString() {
    return 'SpeedData(speeds: $speeds)';
  }
}

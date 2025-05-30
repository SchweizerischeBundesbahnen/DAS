import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sfera/src/model/journey/speeds.dart';
import 'package:sfera/src/model/journey/train_series.dart';

@sealed
@immutable
class SpeedData {
  const SpeedData({this.speeds = const []});

  final List<Speeds> speeds;

  Speeds? speedsFor(TrainSeries? trainSeries, int? breakSeries) {
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

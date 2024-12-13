import 'package:collection/collection.dart';
import 'package:das_client/model/journey/train_series.dart';
import 'package:das_client/model/journey/velocity.dart';

class SpeedData {
  SpeedData({this.velocities = const []});

  final List<Velocity> velocities;

  String? resolvedSpeed(TrainSeries? trainSeries, int? breakSeries) {
    if (trainSeries == null) return null;

    final trainSeriesVelocities = velocities.where((it) => it.trainSeries == trainSeries);
    final exactMatchingVelocity = trainSeriesVelocities.firstWhereOrNull((it) => it.breakSeries == breakSeries);
    return exactMatchingVelocity?.speed ??
        trainSeriesVelocities.firstWhereOrNull((it) => it.breakSeries == null)?.speed;
  }
}

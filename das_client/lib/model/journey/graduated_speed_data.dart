import 'package:collection/collection.dart';
import 'package:das_client/model/journey/graduated_speeds.dart';
import 'package:das_client/model/journey/train_series.dart';

class GraduatedSpeedData {
  GraduatedSpeedData({this.graduatedSpeeds = const []});

  final List<GraduatedSpeeds> graduatedSpeeds;

  GraduatedSpeeds? graduatedSpeedsFor(TrainSeries? trainSeries, int? breakSeries) {
    if (trainSeries == null) return null;

    final trainSeriesGraduatedSpeeds = graduatedSpeeds.where((it) => it.trainSeries == trainSeries);
    final exactMatchingVelocity = trainSeriesGraduatedSpeeds.firstWhereOrNull((it) => it.breakSeries == breakSeries);
    return exactMatchingVelocity ??
        trainSeriesGraduatedSpeeds.firstWhereOrNull((it) => it.breakSeries == null);
  }
}

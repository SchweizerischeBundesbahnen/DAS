import 'package:collection/collection.dart';
import 'package:das_client/model/journey/graduated_station_speeds.dart';
import 'package:das_client/model/journey/train_series.dart';

class StationSpeedData {
  const StationSpeedData({this.graduatedStationSpeeds = const []});

  final List<GraduatedStationSpeeds> graduatedStationSpeeds;

  GraduatedStationSpeeds? graduatedSpeedsFor(TrainSeries? trainSeries) {
    if (trainSeries == null) return null;

    return graduatedStationSpeeds.firstWhereOrNull((it) => it.trainSeries.contains(trainSeries));
  }
}

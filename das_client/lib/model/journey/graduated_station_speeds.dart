import 'package:das_client/model/journey/speed.dart';
import 'package:das_client/model/journey/train_series.dart';

class GraduatedStationSpeeds {
  GraduatedStationSpeeds({
    required this.trainSeries,
    this.text,
    this.incomingSpeeds = const [],
    this.outgoingSpeeds = const [],
  }) : assert(trainSeries.isNotEmpty);

  final List<TrainSeries> trainSeries;
  final String? text;
  final List<Speed> incomingSpeeds;
  final List<Speed> outgoingSpeeds;

  factory GraduatedStationSpeeds.from(List<TrainSeries> trainSeries, String speedString, {String? text}) {
    final parts = speedString.split('/');
    final incomingSpeeds = parts[0].split('-');
    final outgoingSpeeds = parts.length > 1 ? parts[1].split('-') : [];

    // validate station speed format
    final speedRegex = RegExp(Speed.speedRegex);
    final formatSatisfied = [...incomingSpeeds, ...outgoingSpeeds].every((speed) => speedRegex.hasMatch(speed));
    if (incomingSpeeds.isNotEmpty && !formatSatisfied) {
      throw ArgumentError('Invalid graduated station speed format: $speedString');
    }

    return GraduatedStationSpeeds(
      trainSeries: trainSeries,
      text: text,
      incomingSpeeds: incomingSpeeds.map((speed) => Speed.from(speed)).toList(),
      outgoingSpeeds: outgoingSpeeds.map((speed) => Speed.from(speed)).toList(),
    );
  }

  @override
  String toString() {
    return 'GraduatedStationSpeeds(trainSeries: $trainSeries, incomingSpeeds: $incomingSpeeds, outgoingSpeeds: $outgoingSpeeds)';
  }
}

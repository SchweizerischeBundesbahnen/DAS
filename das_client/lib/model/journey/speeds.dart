import 'package:das_client/model/journey/speed.dart';
import 'package:das_client/model/journey/train_series.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
class Speeds {
  const Speeds({
    required this.trainSeries,
    this.text,
    this.breakSeries,
    this.incomingSpeeds = const [],
    this.outgoingSpeeds = const [],
    this.reduced = false,
  });

  final TrainSeries trainSeries;
  final String? text;
  final int? breakSeries;
  final List<Speed> incomingSpeeds;
  final List<Speed> outgoingSpeeds;
  final bool reduced;

  factory Speeds.from(TrainSeries trainSeries, String speedString,
      {String? text, int? breakSeries, bool reduced = false}) {
    final parts = speedString.split('/');
    final incomingSpeeds = parts[0].split('-');
    final outgoingSpeeds = parts.length > 1 ? parts[1].split('-') : [];

    // validate station speed format
    final speedRegex = RegExp(Speed.speedRegex);
    final formatSatisfied = [...incomingSpeeds, ...outgoingSpeeds].every((speed) => speedRegex.hasMatch(speed));
    if (incomingSpeeds.isNotEmpty && !formatSatisfied) {
      throw ArgumentError('Invalid graduated station speed format: $speedString');
    }

    return Speeds(
      trainSeries: trainSeries,
      text: text,
      breakSeries: breakSeries,
      reduced: reduced,
      incomingSpeeds: incomingSpeeds.map((speed) => Speed.from(speed)).toList(),
      outgoingSpeeds: outgoingSpeeds.map((speed) => Speed.from(speed)).toList(),
    );
  }

  @override
  String toString() {
    return 'GraduatedSpeeds(trainSeries: $trainSeries, breakSeries: $breakSeries, incomingSpeeds: $incomingSpeeds, outgoingSpeeds: $outgoingSpeeds, text: $text)';
  }
}

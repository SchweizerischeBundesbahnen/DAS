import 'package:meta/meta.dart';
import 'package:sfera/src/model/journey/speed.dart';
import 'package:sfera/src/model/journey/train_series.dart';

@sealed
@immutable
class TrainSeriesSpeed {
  const TrainSeriesSpeed({
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

  factory TrainSeriesSpeed.from(
    TrainSeries trainSeries,
    String speedString, {
    String? text,
    int? breakSeries,
    bool reduced = false,
  }) {
    final parts = speedString.split('/');
    final List<String> incomingSpeeds = parts[0].split('-');
    final List<String> outgoingSpeeds = parts.length > 1 ? parts[1].split('-') : [];

    // validate station speed format
    final formatSatisfied = [...incomingSpeeds, ...outgoingSpeeds].every(Speed.isValid);
    if (incomingSpeeds.isNotEmpty && !formatSatisfied) {
      throw ArgumentError('Invalid graduated station speed format: $speedString');
    }

    return TrainSeriesSpeed(
      trainSeries: trainSeries,
      text: text,
      breakSeries: breakSeries,
      reduced: reduced,
      incomingSpeeds: incomingSpeeds.map((speed) => Speed.parse(speed)).toList(),
      outgoingSpeeds: outgoingSpeeds.map((speed) => Speed.parse(speed)).toList(),
    );
  }

  @override
  String toString() {
    return 'GraduatedSpeeds(trainSeries: $trainSeries, breakSeries: $breakSeries, incomingSpeeds: $incomingSpeeds, outgoingSpeeds: $outgoingSpeeds, text: $text)';
  }
}

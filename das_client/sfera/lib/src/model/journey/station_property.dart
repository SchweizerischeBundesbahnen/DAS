import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
class StationProperty {
  const StationProperty({this.text, this.sign, this.speeds});

  final String? text;
  final StationSign? sign;
  final List<TrainSeriesSpeed>? speeds;

  @override
  String toString() {
    return 'StationProperty(text: $text, sign: $sign, speeds: $speeds)';
  }
}

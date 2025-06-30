import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
class StationProperty {
  const StationProperty({this.text, this.sign, this.speedData});

  final String? text;
  final StationSign? sign;
  final SpeedData? speedData;

  @override
  String toString() {
    return 'StationProperty(text: $text, sign: $sign, speedData: $speedData)';
  }
}

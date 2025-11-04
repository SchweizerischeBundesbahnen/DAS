import 'package:collection/collection.dart';
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
    return 'StationProperty{text: $text, sign: $sign, speeds: $speeds}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StationProperty &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          sign == other.sign &&
          DeepCollectionEquality().equals(speeds, other.speeds);

  @override
  int get hashCode => text.hashCode ^ sign.hashCode ^ Object.hashAll(speeds ?? []);
}

import 'package:sfera/src/model/journey/train_series.dart';

class FootNote {
  FootNote({
    required this.text,
    this.type,
    this.refText,
    this.identifier,
    this.trainSeries = const <TrainSeries>[],
  });

  final String text;
  final FootNoteType? type;
  final String? refText;
  final String? identifier;
  final List<TrainSeries> trainSeries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FootNote &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          type == other.type &&
          refText == other.refText &&
          identifier == other.identifier;

  @override
  int get hashCode => text.hashCode ^ type.hashCode ^ refText.hashCode ^ identifier.hashCode;
}

enum FootNoteType { trackSpeed, decisiveGradientUp, decisiveGradientDown, contact, networkType, journey }

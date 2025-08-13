import 'package:sfera/component.dart';

class JourneyPositionModel {
  JourneyPositionModel({this.currentPosition});

  final JourneyPoint? currentPosition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is JourneyPositionModel && other.currentPosition == currentPosition);

  @override
  int get hashCode => currentPosition.hashCode;

  @override
  String toString() =>
      'JourneyPositionModel('
      'currentPosition: $currentPosition'
      ')';
}

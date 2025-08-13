import 'package:sfera/component.dart';

class JourneyPositionModel {
  JourneyPositionModel({this.currentPosition, this.lastServicePoint});

  final JourneyPoint? currentPosition;
  final ServicePoint? lastServicePoint;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JourneyPositionModel &&
          currentPosition == other.currentPosition &&
          lastServicePoint == other.lastServicePoint);

  @override
  int get hashCode => currentPosition.hashCode ^ lastServicePoint.hashCode;

  @override
  String toString() =>
      'JourneyPositionModel('
      'currentPosition: $currentPosition'
      ', lastServicePoint: $lastServicePoint'
      ')';
}

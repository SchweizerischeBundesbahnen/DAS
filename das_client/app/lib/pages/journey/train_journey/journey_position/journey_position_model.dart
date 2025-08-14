import 'package:sfera/component.dart';

class JourneyPositionModel {
  JourneyPositionModel({this.currentPosition, this.lastPosition, this.lastServicePoint});

  final JourneyPoint? currentPosition;
  final JourneyPoint? lastPosition;
  final ServicePoint? lastServicePoint;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JourneyPositionModel &&
          currentPosition == other.currentPosition &&
          lastPosition == other.lastPosition &&
          lastServicePoint == other.lastServicePoint);

  @override
  int get hashCode => currentPosition.hashCode ^ lastPosition.hashCode ^ lastServicePoint.hashCode;

  @override
  String toString() =>
      'JourneyPositionModel('
      'currentPosition: $currentPosition'
      ', lastPosition: $lastPosition'
      ', lastServicePoint: $lastServicePoint'
      ')';
}

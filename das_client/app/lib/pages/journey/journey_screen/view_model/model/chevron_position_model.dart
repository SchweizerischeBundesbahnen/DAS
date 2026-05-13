import 'package:sfera/component.dart';

class ChevronPositionModel {
  ChevronPositionModel({
    this.currentPosition,
    this.lastPosition,
  });

  final JourneyPoint? currentPosition;

  final JourneyPoint? lastPosition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChevronPositionModel &&
          runtimeType == other.runtimeType &&
          currentPosition == other.currentPosition &&
          lastPosition == other.lastPosition;

  @override
  int get hashCode => Object.hash(currentPosition, lastPosition);

  @override
  String toString() {
    return 'ChevronPositionModel{currentPosition: $currentPosition, lastPosition: $lastPosition}';
  }
}

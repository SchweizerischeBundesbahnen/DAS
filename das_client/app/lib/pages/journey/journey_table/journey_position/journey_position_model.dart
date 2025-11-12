import 'package:sfera/component.dart';

class JourneyPositionModel {
  JourneyPositionModel({
    this.currentPosition,
    this.lastPosition,
    this.previousServicePoint,
    this.nextServicePoint,
    this.previousStop,
    this.nextStop,
  });

  final JourneyPoint? currentPosition;

  /// This is the [currentPosition] from the previously received position and journey update.
  ///
  /// Since journey updates can occur without position updates, this can be equal to [currentPosition].
  final JourneyPoint? lastPosition;

  /// This is the service point closest to [currentPosition] that has already been passed.
  final ServicePoint? previousServicePoint;

  /// This is the service point closest to [currentPosition] that is still ahead.
  final ServicePoint? nextServicePoint;

  /// This is service point closest to [currentPosition] that has already been passed and is a stop.
  final ServicePoint? previousStop;

  /// This is service point closest to [currentPosition] that is still ahead and is a stop.
  final ServicePoint? nextStop;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JourneyPositionModel &&
          currentPosition == other.currentPosition &&
          lastPosition == other.lastPosition &&
          previousServicePoint == other.previousServicePoint &&
          nextServicePoint == other.nextServicePoint &&
          previousStop == other.previousStop &&
          nextStop == other.nextStop);

  @override
  int get hashCode => Object.hash(
    currentPosition,
    lastPosition,
    previousServicePoint,
    nextServicePoint,
    previousStop,
    nextStop,
  );

  @override
  String toString() {
    return 'JourneyPositionModel{'
        'currentPosition: $currentPosition, '
        'lastPosition: $lastPosition, '
        'previousServicePoint: $previousServicePoint, '
        'nextServicePoint: $nextServicePoint, '
        'previousStop: $previousStop, '
        'nextStop: $nextStop'
        '}';
  }
}

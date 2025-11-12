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

  /// The position of the vehicle in the journey indicating the last point **that has been passed**.
  ///
  /// Is usually set by an event received from TMS VAD, but can be set manually by the train driver
  /// or with respect to time.
  final JourneyPoint? currentPosition;

  /// The [currentPosition] from the previously received position and journey update.
  ///
  /// Since journey updates can occur without position updates, this can be equal to [currentPosition].
  final JourneyPoint? lastPosition;

  /// The service point closest to [currentPosition] that has already been passed.
  final ServicePoint? previousServicePoint;

  /// The service point closest to [currentPosition] that is still ahead.
  final ServicePoint? nextServicePoint;

  /// The service point closest to [currentPosition] that has already been passed and is a stop.
  final ServicePoint? previousStop;

  /// The service point closest to [currentPosition] that is still ahead and is a stop.
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

import 'package:sfera/component.dart';

class JourneyPositionModel({
  this.currentPosition,
  this.lastPosition,
  this.previousServicePoint,
  this.nextServicePoint,
  this.previousStop,
  this.nextStop,
  this.isManualPosition = false,
  this.isTrainInMotion = false,
}) {
  /// The position of the vehicle in the journey indicating the last point **that has been passed**.
  ///
  /// Is usually set by an event received from TMS VAD, but can be set manually by the train driver
  /// or with respect to time.
  final JourneyPoint? currentPosition;

  /// The previous [currentPosition], when the currentPosition **actually changed**.
  ///
  /// This will stay the same if the [currentPosition] is updated twice to the same position.
  final JourneyPoint? lastPosition;

  /// The service point closest to [currentPosition] that has already been passed.
  final ServicePoint? previousServicePoint;

  /// The service point closest to [currentPosition] that is still ahead.
  final ServicePoint? nextServicePoint;

  /// The service point closest to [currentPosition] that has already been passed and is a stop.
  final ServicePoint? previousStop;

  /// The service point closest to [currentPosition] that is still ahead and is a stop.
  final ServicePoint? nextStop;

  /// Whether the [currentPosition] was set manually by the train driver.
  final bool isManualPosition;

  /// Whether the train is on its way, meaning the [currentPosition] lies between the first and the last service point.
  final bool isTrainInMotion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JourneyPositionModel &&
          currentPosition == other.currentPosition &&
          lastPosition == other.lastPosition &&
          previousServicePoint == other.previousServicePoint &&
          nextServicePoint == other.nextServicePoint &&
          previousStop == other.previousStop &&
          nextStop == other.nextStop &&
          isManualPosition == other.isManualPosition &&
          isTrainInMotion == other.isTrainInMotion);

  @override
  int get hashCode => Object.hash(
    currentPosition,
    lastPosition,
    previousServicePoint,
    nextServicePoint,
    previousStop,
    nextStop,
    isManualPosition,
    isTrainInMotion,
  );

  @override
  String toString() {
    return 'JourneyPositionModel{'
        'currentPosition: ${currentPosition?.toPositionRelevantString()}, '
        'lastPosition: ${lastPosition?.toPositionRelevantString()}, '
        'previousServicePoint: ${previousServicePoint?.toPositionRelevantString()}, '
        'nextServicePoint: ${nextServicePoint?.toPositionRelevantString()}, '
        'previousStop: ${previousStop?.toPositionRelevantString()}, '
        'nextStop: ${nextStop?.toPositionRelevantString()}, '
        'isManualPosition: $isManualPosition, '
        'isTrainInMotion: $isTrainInMotion'
        '}';
  }
}

extension _JourneyPointX on JourneyPoint {
  String toPositionRelevantString() => '$runtimeType{order: $order, kilometre: $kilometre}';
}

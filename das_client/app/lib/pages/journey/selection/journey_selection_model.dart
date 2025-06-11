import 'package:app/util/error_code.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

/// Represents the state of the journey selection process.
sealed class JourneySelectionModel {
  const JourneySelectionModel._();

  factory JourneySelectionModel.selecting({
    required DateTime startDate,
    required RailwayUndertaking railwayUndertaking,
    String? trainNumber,
  }) = Selecting;

  factory JourneySelectionModel.loading({required TrainIdentification trainIdentification}) = Loading;

  factory JourneySelectionModel.loaded({required TrainIdentification trainIdentification}) = Loaded;

  factory JourneySelectionModel.error({
    required TrainIdentification trainIdentification,
    required ErrorCode errorCode,
  }) = Error;

  bool get isStartDateSameAsToday => DateUtils.isSameDay(startDate, clock.now());

  String get operationalTrainNumber => switch (this) {
    final Selecting s => s.trainNumber ?? '',
    final Loading l => l.trainIdentification.trainNumber,
    final Loaded l => l.trainIdentification.trainNumber,
    final Error e => e.trainIdentification.trainNumber,
  };

  DateTime get startDate => switch (this) {
    final Selecting s => s.startDate,
    final Loading l => l.trainIdentification.date,
    final Loaded l => l.trainIdentification.date,
    final Error e => e.trainIdentification.date,
  };

  RailwayUndertaking get railwayUndertaking => switch (this) {
    final Selecting s => s.railwayUndertaking,
    final Loading l => l.trainIdentification.ru,
    final Loaded l => l.trainIdentification.ru,
    final Error e => e.trainIdentification.ru,
  };

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class Selecting extends JourneySelectionModel {
  const Selecting({
    required this.startDate,
    required this.railwayUndertaking,
    this.trainNumber,
    this.isInputComplete = false,
  }) : super._();
  @override
  final DateTime startDate;
  @override
  final RailwayUndertaking railwayUndertaking;
  final String? trainNumber;
  final bool isInputComplete;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Selecting &&
          runtimeType == other.runtimeType &&
          trainNumber == other.trainNumber &&
          startDate == other.startDate &&
          railwayUndertaking == other.railwayUndertaking &&
          isInputComplete == other.isInputComplete;

  @override
  int get hashCode => Object.hash(runtimeType, trainNumber, startDate, railwayUndertaking, isInputComplete);

  Selecting copyWith({
    String? operationalTrainNumber,
    DateTime? startDate,
    RailwayUndertaking? railwayUndertaking,
    bool? isInputComplete,
  }) {
    return Selecting(
      trainNumber: operationalTrainNumber ?? trainNumber,
      startDate: startDate ?? this.startDate,
      railwayUndertaking: railwayUndertaking ?? this.railwayUndertaking,
      isInputComplete: isInputComplete ?? this.isInputComplete,
    );
  }
}

class Loading extends JourneySelectionModel {
  const Loading({
    required this.trainIdentification,
  }) : super._();

  final TrainIdentification trainIdentification;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Loading && runtimeType == other.runtimeType && trainIdentification == other.trainIdentification;

  @override
  int get hashCode => Object.hash(runtimeType, trainIdentification);
}

class Loaded extends JourneySelectionModel {
  const Loaded({
    required this.trainIdentification,
  }) : super._();

  final TrainIdentification trainIdentification;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Loaded && runtimeType == other.runtimeType && trainIdentification == other.trainIdentification;

  @override
  int get hashCode => Object.hash(runtimeType, trainIdentification);
}

class Error extends JourneySelectionModel {
  const Error({
    required this.trainIdentification,
    required this.errorCode,
  }) : super._();
  final TrainIdentification trainIdentification;
  final ErrorCode errorCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error &&
          runtimeType == other.runtimeType &&
          trainIdentification == other.trainIdentification &&
          errorCode == other.errorCode;

  @override
  int get hashCode => Object.hash(runtimeType, trainIdentification, errorCode);
}

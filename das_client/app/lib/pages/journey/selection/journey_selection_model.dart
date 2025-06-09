import 'package:app/util/error_code.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

sealed class JourneySelectionModel {
  const JourneySelectionModel._();

  factory JourneySelectionModel.selecting({
    required DateTime startDate,
    required RailwayUndertaking railwayUndertaking,
    String? trainNumber,
  }) = Selecting;

  factory JourneySelectionModel.loading({required TrainIdentification trainJourneyIdentification}) = Loading;

  factory JourneySelectionModel.loaded({required TrainIdentification trainJourneyIdentification}) = Loaded;

  factory JourneySelectionModel.error({
    required TrainIdentification trainJourneyIdentification,
    required ErrorCode errorCode,
  }) = Error;

  bool get isStartDateSameAsToday => switch (this) {
    final Selecting selecting => DateUtils.isSameDay(selecting.startDate, clock.now()),
    final Loading loading => DateUtils.isSameDay(loading.trainJourneyIdentification.date, clock.now()),
    final Loaded loaded => DateUtils.isSameDay(loaded.trainJourneyIdentification.date, clock.now()),
    final Error error => DateUtils.isSameDay(error.trainJourneyIdentification.date, clock.now()),
  };

  String get operationalTrainNumber => switch (this) {
    final Selecting selecting => selecting.trainNumber ?? '',
    final Loading loading => loading.trainJourneyIdentification.trainNumber,
    final Loaded loaded => loaded.trainJourneyIdentification.trainNumber,
    final Error error => error.trainJourneyIdentification.trainNumber,
  };

  DateTime get startDate => switch (this) {
    final Selecting selecting => selecting.startDate,
    final Loading loading => loading.trainJourneyIdentification.date,
    final Loaded loaded => loaded.trainJourneyIdentification.date,
    final Error error => error.trainJourneyIdentification.date,
  };

  RailwayUndertaking get railwayUndertaking => switch (this) {
    final Selecting selecting => selecting.railwayUndertaking,
    final Loading loading => loading.trainJourneyIdentification.ru,
    final Loaded loaded => loaded.trainJourneyIdentification.ru,
    final Error error => error.trainJourneyIdentification.ru,
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
    required this.trainJourneyIdentification,
  }) : super._();

  final TrainIdentification trainJourneyIdentification;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Loading &&
          runtimeType == other.runtimeType &&
          trainJourneyIdentification == other.trainJourneyIdentification;

  @override
  int get hashCode => Object.hash(runtimeType, trainJourneyIdentification);

  Loading copyWith({
    TrainIdentification? trainJourneyIdentification,
  }) {
    return Loading(
      trainJourneyIdentification: trainJourneyIdentification ?? this.trainJourneyIdentification,
    );
  }
}

class Loaded extends JourneySelectionModel {
  const Loaded({
    required this.trainJourneyIdentification,
  }) : super._();

  final TrainIdentification trainJourneyIdentification;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Loaded &&
          runtimeType == other.runtimeType &&
          trainJourneyIdentification == other.trainJourneyIdentification;

  @override
  int get hashCode => Object.hash(runtimeType, trainJourneyIdentification);
}

class Error extends JourneySelectionModel {
  const Error({
    required this.trainJourneyIdentification,
    required this.errorCode,
  }) : super._();
  final TrainIdentification trainJourneyIdentification;
  final ErrorCode errorCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error &&
          runtimeType == other.runtimeType &&
          trainJourneyIdentification == other.trainJourneyIdentification &&
          errorCode == other.errorCode;

  @override
  int get hashCode => Object.hash(runtimeType, trainJourneyIdentification, errorCode);
}

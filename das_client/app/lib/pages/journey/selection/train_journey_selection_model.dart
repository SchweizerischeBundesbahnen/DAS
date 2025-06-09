import 'package:app/util/error_code.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

sealed class TrainJourneySelectionModel {
  const TrainJourneySelectionModel._();

  factory TrainJourneySelectionModel.selecting({
    required DateTime startDate,
    required RailwayUndertaking railwayUndertaking,
    String? trainNumber,
  }) = Selecting;

  factory TrainJourneySelectionModel.loading({required TrainIdentification trainJourneyIdentification}) = Loading;

  factory TrainJourneySelectionModel.loaded({required TrainIdentification trainJourneyIdentification}) = Loaded;

  factory TrainJourneySelectionModel.error({
    required ErrorCode errorCode,
    String? trainNumber,
    DateTime? startDate,
    RailwayUndertaking? railwayUndertaking,
  }) = Error;

  bool get isStartDateSameAsToday => switch (this) {
    final Selecting selecting => DateUtils.isSameDay(selecting.startDate, clock.now()),
    final Loading loading => DateUtils.isSameDay(loading.trainJourneyIdentification.date, clock.now()),
    final Loaded loaded => DateUtils.isSameDay(loaded.trainJourneyIdentification.date, clock.now()),
    final Error error => error.startDate != null && DateUtils.isSameDay(error.startDate!, clock.now()),
  };

  String get operationalTrainNumber => switch (this) {
    final Selecting selecting => selecting.trainNumber ?? '',
    final Loading loading => loading.trainJourneyIdentification.trainNumber,
    final Loaded loaded => loaded.trainJourneyIdentification.trainNumber,
    final Error error => error.trainNumber ?? '',
  };

  get selectedDate => switch (this) {
    final Selecting selecting => selecting.startDate,
    final Loading loading => loading.trainJourneyIdentification.date,
    final Loaded loaded => loaded.trainJourneyIdentification.date,
    final Error error => error.startDate ?? clock.now(),
  };

  get railwayUndertaking => switch (this) {
    final Selecting selecting => selecting.railwayUndertaking,
    final Loading loading => loading.trainJourneyIdentification.ru,
    final Loaded loaded => loaded.trainJourneyIdentification.ru,
    final Error error => error.railwayUndertaking ?? RailwayUndertaking.sbbP,
  };

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class Selecting extends TrainJourneySelectionModel {
  const Selecting({
    required this.startDate,
    required this.railwayUndertaking,
    this.trainNumber,
    this.isInputComplete = false,
  }) : super._();
  final DateTime startDate;
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
      trainNumber: operationalTrainNumber ?? this.trainNumber,
      startDate: startDate ?? this.startDate,
      railwayUndertaking: railwayUndertaking ?? this.railwayUndertaking,
      isInputComplete: isInputComplete ?? this.isInputComplete,
    );
  }
}

class Loading extends TrainJourneySelectionModel {
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

class Loaded extends TrainJourneySelectionModel {
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

  Loaded copyWith({
    TrainIdentification? trainJourneyIdentification,
  }) {
    return Loaded(
      trainJourneyIdentification: trainJourneyIdentification ?? this.trainJourneyIdentification,
    );
  }
}

class Error extends TrainJourneySelectionModel {
  const Error({
    this.trainNumber,
    this.startDate,
    this.railwayUndertaking,
    required this.errorCode,
  }) : super._();
  final String? trainNumber;
  final DateTime? startDate;
  final RailwayUndertaking? railwayUndertaking;
  final ErrorCode errorCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error &&
          runtimeType == other.runtimeType &&
          trainNumber == other.trainNumber &&
          startDate == other.startDate &&
          railwayUndertaking == other.railwayUndertaking &&
          errorCode == other.errorCode;

  @override
  int get hashCode => Object.hash(runtimeType, trainNumber, startDate, railwayUndertaking, errorCode);

  Error copyWith({
    String? operationalTrainNumber,
    DateTime? startDate,
    RailwayUndertaking? railwayUndertaking,
    ErrorCode? errorCode,
  }) {
    return Error(
      trainNumber: operationalTrainNumber ?? this.trainNumber,
      startDate: startDate ?? this.startDate,
      railwayUndertaking: railwayUndertaking ?? this.railwayUndertaking,
      errorCode: errorCode ?? this.errorCode,
    );
  }
}

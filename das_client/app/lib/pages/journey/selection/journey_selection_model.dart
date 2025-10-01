import 'package:app/util/error_code.dart';
import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

/// Represents the state of the journey selection process.
sealed class JourneySelectionModel {
  const JourneySelectionModel._();

  factory JourneySelectionModel.selecting({
    required DateTime startDate,
    required RailwayUndertaking railwayUndertaking,
    required List<DateTime> availableStartDates,
    required List<RailwayUndertaking> availableRailwayUndertakings,
    String? trainNumber,
    String? railwayUndertakingFilter,
  }) = Selecting;

  factory JourneySelectionModel.loading({required TrainIdentification trainIdentification}) = Loading;

  factory JourneySelectionModel.loaded({required TrainIdentification trainIdentification}) = Loaded;

  factory JourneySelectionModel.error({
    required TrainIdentification trainIdentification,
    required List<DateTime> availableStartDates,
    required List<RailwayUndertaking> availableRailwayUndertakings,
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

  List<DateTime> get availableStartDates => switch (this) {
    final Selecting s => s.availableStartDates,
    final Loading _ => [],
    final Loaded _ => [],
    final Error e => e.availableStartDates,
  };

  List<RailwayUndertaking> get availableRailwayUndertakings => switch (this) {
    final Selecting s => s.availableRailwayUndertakings,
    final Loading _ => [],
    final Loaded _ => [],
    final Error e => e.availableRailwayUndertakings,
  };

  RailwayUndertaking get railwayUndertaking => switch (this) {
    final Selecting s => s.railwayUndertaking,
    final Loading l => l.trainIdentification.ru,
    final Loaded l => l.trainIdentification.ru,
    final Error e => e.trainIdentification.ru,
  };

  String? get railwayUndertakingFilter => switch (this) {
    final Selecting s => s.railwayUndertakingFilter,
    final Loading l => l.trainIdentification.ru.companyCode,
    final Loaded l => l.trainIdentification.ru.companyCode,
    final Error e => e.trainIdentification.ru.companyCode,
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
    required this.availableStartDates,
    required this.availableRailwayUndertakings,
    this.trainNumber,
    this.railwayUndertakingFilter,
    this.isInputComplete = false,
  }) : super._();
  @override
  final DateTime startDate;
  @override
  final List<DateTime> availableStartDates;
  @override
  final RailwayUndertaking railwayUndertaking;
  @override
  final List<RailwayUndertaking> availableRailwayUndertakings;
  final String? trainNumber;
  @override
  final String? railwayUndertakingFilter;
  final bool isInputComplete;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Selecting &&
          runtimeType == other.runtimeType &&
          trainNumber == other.trainNumber &&
          startDate == other.startDate &&
          ListEquality().equals(availableStartDates, other.availableStartDates) &&
          railwayUndertaking == other.railwayUndertaking &&
          ListEquality().equals(availableRailwayUndertakings, other.availableRailwayUndertakings) &&
          railwayUndertakingFilter == other.railwayUndertakingFilter &&
          isInputComplete == other.isInputComplete;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    trainNumber,
    startDate,
    availableStartDates,
    railwayUndertaking,
    railwayUndertakingFilter,
    availableRailwayUndertakings,
    isInputComplete,
  );

  Selecting copyWith({
    String? operationalTrainNumber,
    DateTime? startDate,
    List<DateTime>? availableStartDates,
    RailwayUndertaking? railwayUndertaking,
    String? railwayUndertakingFilter,
    List<RailwayUndertaking>? availableRailwayUndertakings,
    bool? isInputComplete,
  }) {
    return Selecting(
      trainNumber: operationalTrainNumber ?? trainNumber,
      startDate: startDate ?? this.startDate,
      availableStartDates: availableStartDates ?? this.availableStartDates,
      railwayUndertaking: railwayUndertaking ?? this.railwayUndertaking,
      railwayUndertakingFilter: railwayUndertakingFilter ?? this.railwayUndertakingFilter,
      availableRailwayUndertakings: availableRailwayUndertakings ?? this.availableRailwayUndertakings,
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
    required this.availableStartDates,
    required this.availableRailwayUndertakings,
  }) : super._();
  final TrainIdentification trainIdentification;
  @override
  final List<DateTime> availableStartDates;
  @override
  final List<RailwayUndertaking> availableRailwayUndertakings;
  final ErrorCode errorCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error &&
          runtimeType == other.runtimeType &&
          trainIdentification == other.trainIdentification &&
          ListEquality().equals(availableStartDates, other.availableStartDates) &&
          ListEquality().equals(availableRailwayUndertakings, other.availableRailwayUndertakings) &&
          errorCode == other.errorCode;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    trainIdentification,
    errorCode,
    availableStartDates,
    availableRailwayUndertakings,
  );
}

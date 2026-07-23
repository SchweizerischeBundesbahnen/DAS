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
    required List<DateTime> availableStartDates,
    RailwayUndertaking? railwayUndertaking,
    String? trainNumber,
  }) = Selecting;

  factory JourneySelectionModel.loading({required TrainIdentification trainIdentification}) = Loading;

  factory JourneySelectionModel.loadingCompanyMatches({required DateTime startDate, required String trainNumber}) =
      LoadingCompanyMatches;

  factory JourneySelectionModel.selectingCompanyMatch({
    required DateTime startDate,
    required List<DateTime> availableStartDates,
    required Set<CompanyMatch> companyMatches,
    required String trainNumber,
    required CompanyMatch? selectedCompanyMatch,
    required bool isInputComplete,
  }) = SelectingCompanyMatch;

  factory JourneySelectionModel.loaded({required TrainIdentification trainIdentification}) = Loaded;

  factory JourneySelectionModel.error({
    required TrainIdentification trainIdentification,
    required List<DateTime> availableStartDates,
    required ErrorCode errorCode,
  }) = Error;

  bool get isStartDateSameAsToday => DateUtils.isSameDay(startDate, clock.now());

  String get operationalTrainNumber => switch (this) {
    final Selecting s => s.trainNumber ?? '',
    final LoadingCompanyMatches l => l.trainNumber,
    final SelectingCompanyMatch s => s.trainNumber ?? '',
    final Loading l => l.trainIdentification.trainNumber,
    final Loaded l => l.trainIdentification.trainNumber,
    final Error e => e.trainIdentification.trainNumber,
  };

  DateTime get startDate => switch (this) {
    final Selecting s => s.startDate,
    final LoadingCompanyMatches l => l.startDate,
    final SelectingCompanyMatch s => s.startDate,
    final Loading l => l.trainIdentification.date,
    final Loaded l => l.trainIdentification.date,
    final Error e => e.trainIdentification.date,
  };

  List<DateTime> get availableStartDates => switch (this) {
    final Selecting s => s.availableStartDates,
    final LoadingCompanyMatches _ => [],
    final SelectingCompanyMatch s => s.availableStartDates,
    final Loading _ => [],
    final Loaded _ => [],
    final Error e => e.availableStartDates,
  };

  RailwayUndertaking? get railwayUndertaking => switch (this) {
    final Selecting s => s.railwayUndertaking,
    final LoadingCompanyMatches _ => null,
    final SelectingCompanyMatch _ => null,
    final Loading l => l.trainIdentification.ru,
    final Loaded l => l.trainIdentification.ru,
    final Error e => e.trainIdentification.ru,
  };

  bool get isInputComplete => switch (this) {
    final Selecting s => s.isInputComplete,
    final LoadingCompanyMatches _ => false,
    final SelectingCompanyMatch s => s.isInputComplete,
    final Loading _ => false,
    final Loaded _ => true,
    final Error _ => false,
  };
}

class Selecting extends JourneySelectionModel {
  const Selecting({
    required this.startDate,
    required this.availableStartDates,
    this.railwayUndertaking,
    this.trainNumber,
    this.isInputComplete = false,
  }) : super._();
  @override
  final DateTime startDate;
  @override
  final List<DateTime> availableStartDates;
  @override
  final RailwayUndertaking? railwayUndertaking;
  final String? trainNumber;
  @override
  final bool isInputComplete;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Selecting &&
          runtimeType == other.runtimeType &&
          trainNumber == other.trainNumber &&
          startDate == other.startDate &&
          const ListEquality().equals(availableStartDates, other.availableStartDates) &&
          railwayUndertaking == other.railwayUndertaking &&
          isInputComplete == other.isInputComplete;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    trainNumber,
    startDate,
    availableStartDates,
    railwayUndertaking,
    isInputComplete,
  );

  Selecting copyWith({
    String? operationalTrainNumber,
    DateTime? startDate,
    List<DateTime>? availableStartDates,
    RailwayUndertaking? railwayUndertaking,
    bool? isInputComplete,
  }) {
    return Selecting(
      trainNumber: operationalTrainNumber ?? trainNumber,
      startDate: startDate ?? this.startDate,
      availableStartDates: availableStartDates ?? this.availableStartDates,
      railwayUndertaking: railwayUndertaking ?? this.railwayUndertaking,
      isInputComplete: isInputComplete ?? this.isInputComplete,
    );
  }

  @override
  String toString() {
    return 'Selecting{startDate: $startDate, availableStartDates: $availableStartDates, railwayUndertaking: $railwayUndertaking, trainNumber: $trainNumber, isInputComplete: $isInputComplete}';
  }
}

class SelectingCompanyMatch extends JourneySelectionModel {
  const SelectingCompanyMatch({
    required this.startDate,
    required this.availableStartDates,
    required this.companyMatches,
    this.trainNumber,
    this.selectedCompanyMatch,
    this.isInputComplete = false,
  }) : super._();
  @override
  final DateTime startDate;
  @override
  final List<DateTime> availableStartDates;
  final String? trainNumber;
  @override
  final bool isInputComplete;
  final Set<CompanyMatch> companyMatches;
  final CompanyMatch? selectedCompanyMatch;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectingCompanyMatch &&
          runtimeType == other.runtimeType &&
          trainNumber == other.trainNumber &&
          startDate == other.startDate &&
          const ListEquality().equals(availableStartDates, other.availableStartDates) &&
          const SetEquality().equals(companyMatches, other.companyMatches) &&
          selectedCompanyMatch == other.selectedCompanyMatch &&
          isInputComplete == other.isInputComplete;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    trainNumber,
    startDate,
    availableStartDates,
    companyMatches,
    selectedCompanyMatch,
    isInputComplete,
  );

  SelectingCompanyMatch copyWith({
    String? operationalTrainNumber,
    DateTime? startDate,
    List<DateTime>? availableStartDates,
    CompanyMatch? selectedCompanyMatch,
    Set<CompanyMatch>? companyMatches,
    bool? isInputComplete,
  }) {
    return SelectingCompanyMatch(
      trainNumber: operationalTrainNumber ?? trainNumber,
      startDate: startDate ?? this.startDate,
      availableStartDates: availableStartDates ?? this.availableStartDates,
      selectedCompanyMatch: selectedCompanyMatch ?? this.selectedCompanyMatch,
      isInputComplete: isInputComplete ?? this.isInputComplete,
      companyMatches: companyMatches ?? this.companyMatches,
    );
  }

  @override
  String toString() {
    return 'SelectingCompanyMatch{startDate: $startDate, availableStartDates: $availableStartDates, selectedCompanyMatch: $selectedCompanyMatch, trainNumber: $trainNumber, isInputComplete: $isInputComplete, companyMatches: $companyMatches}';
  }
}

class LoadingCompanyMatches extends JourneySelectionModel {
  const LoadingCompanyMatches({
    required this.startDate,
    required this.trainNumber,
  }) : super._();
  @override
  final DateTime startDate;
  final String trainNumber;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingCompanyMatches &&
          runtimeType == other.runtimeType &&
          trainNumber == other.trainNumber &&
          startDate == other.startDate;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    trainNumber,
    startDate,
  );

  @override
  String toString() {
    return 'LoadingCompanyMatches{startDate: $startDate, trainNumber: $trainNumber}';
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

  @override
  String toString() {
    return 'Loading{trainIdentification: $trainIdentification}';
  }
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

  @override
  String toString() {
    return 'Loaded{trainIdentification: $trainIdentification}';
  }
}

class Error extends JourneySelectionModel {
  const Error({
    required this.trainIdentification,
    required this.errorCode,
    required this.availableStartDates,
  }) : super._();
  final TrainIdentification trainIdentification;
  @override
  final List<DateTime> availableStartDates;
  final ErrorCode errorCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error &&
          runtimeType == other.runtimeType &&
          trainIdentification == other.trainIdentification &&
          const ListEquality().equals(availableStartDates, other.availableStartDates) &&
          errorCode == other.errorCode;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    trainIdentification,
    errorCode,
    availableStartDates,
  );

  @override
  String toString() {
    return 'Error{trainIdentification: $trainIdentification, availableStartDates: $availableStartDates, errorCode: $errorCode}';
  }
}

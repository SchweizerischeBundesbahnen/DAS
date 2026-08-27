import 'package:app/util/error_code.dart';
import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:flutter/material.dart';

/// Represents the state of the journey selection process.
sealed class const JourneySelectionModel._() {
  factory JourneySelectionModel.selecting({
    required DateTime startDate,
    required List<DateTime> availableStartDates,
    String? companyCode,
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

  String? get companyCode => switch (this) {
    final Selecting s => s.companyCode,
    final LoadingCompanyMatches _ => null,
    final SelectingCompanyMatch _ => null,
    final Loading l => l.trainIdentification.companyCode,
    final Loaded l => l.trainIdentification.companyCode,
    final Error e => e.trainIdentification.companyCode,
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

class const Selecting({
  @override required final DateTime startDate,
  @override required final List<DateTime> availableStartDates,
  @override final String? companyCode,
  @override final bool isInputComplete = false,
  final String? trainNumber,
}) extends JourneySelectionModel {
  this : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Selecting &&
          runtimeType == other.runtimeType &&
          trainNumber == other.trainNumber &&
          startDate == other.startDate &&
          const ListEquality().equals(availableStartDates, other.availableStartDates) &&
          companyCode == other.companyCode &&
          isInputComplete == other.isInputComplete;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    trainNumber,
    startDate,
    availableStartDates,
    companyCode,
    isInputComplete,
  );

  Selecting copyWith({
    String? operationalTrainNumber,
    DateTime? startDate,
    List<DateTime>? availableStartDates,
    String? companyCode,
    bool? isInputComplete,
  }) {
    return Selecting(
      trainNumber: operationalTrainNumber ?? trainNumber,
      startDate: startDate ?? this.startDate,
      availableStartDates: availableStartDates ?? this.availableStartDates,
      companyCode: companyCode ?? this.companyCode,
      isInputComplete: isInputComplete ?? this.isInputComplete,
    );
  }

  @override
  String toString() {
    return 'Selecting{startDate: $startDate, availableStartDates: $availableStartDates, companyCode: $companyCode, trainNumber: $trainNumber, isInputComplete: $isInputComplete}';
  }
}

class const SelectingCompanyMatch({
  @override required final DateTime startDate,
  @override required final List<DateTime> availableStartDates,
  required final Set<CompanyMatch> companyMatches,
  final String? trainNumber,
  final CompanyMatch? selectedCompanyMatch,
  @override final bool isInputComplete = false,
}) extends JourneySelectionModel {
  this : super._();

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

class const LoadingCompanyMatches({
  @override required final DateTime startDate,
  required final String trainNumber,
}) extends JourneySelectionModel {
  this : super._();

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

class const Loading({required final TrainIdentification trainIdentification}) extends JourneySelectionModel {
  this : super._();

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

class const Loaded({required final TrainIdentification trainIdentification}) extends JourneySelectionModel {
  this : super._();

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

class const Error({
  required final TrainIdentification trainIdentification,
  required final ErrorCode errorCode,
  @override required final List<DateTime> availableStartDates,
}) extends JourneySelectionModel {
  this : super._();

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

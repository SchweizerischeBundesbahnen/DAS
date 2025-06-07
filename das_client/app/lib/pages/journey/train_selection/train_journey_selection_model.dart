import 'package:app/util/error_code.dart';
import 'package:sfera/component.dart';

sealed class TrainJourneySelectionModel {
  const TrainJourneySelectionModel._();

  // implement factories for each state
  factory TrainJourneySelectionModel.selecting({
    required DateTime startDate,
    required RailwayUndertaking railwayUndertaking,
    String? operationalTrainNumber,
  }) = Selecting;

  factory TrainJourneySelectionModel.loading({required TrainIdentification trainJourneyIdentification}) = Loading;

  factory TrainJourneySelectionModel.loaded({required TrainIdentification trainJourneyIdentification}) = Loaded;

  factory TrainJourneySelectionModel.error({
    required ErrorCode errorCode,
    String? operationalTrainNumber,
    DateTime? startDate,
    RailwayUndertaking? railwayUndertaking,
  }) = Error;

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class Selecting extends TrainJourneySelectionModel {
  const Selecting({
    required this.startDate,
    required this.railwayUndertaking,
    this.operationalTrainNumber,
    this.isInputComplete = false,
  }) : super._();
  final DateTime startDate;
  final RailwayUndertaking railwayUndertaking;
  final String? operationalTrainNumber;
  final bool isInputComplete;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Selecting &&
          runtimeType == other.runtimeType &&
          operationalTrainNumber == other.operationalTrainNumber &&
          startDate == other.startDate &&
          railwayUndertaking == other.railwayUndertaking &&
          isInputComplete == other.isInputComplete;

  @override
  int get hashCode => Object.hash(runtimeType, operationalTrainNumber, startDate, railwayUndertaking, isInputComplete);

  Selecting copyWith({
    String? operationalTrainNumber,
    DateTime? startDate,
    RailwayUndertaking? railwayUndertaking,
    bool? isInputComplete,
  }) {
    return Selecting(
      operationalTrainNumber: operationalTrainNumber ?? this.operationalTrainNumber,
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
    this.operationalTrainNumber,
    this.startDate,
    this.railwayUndertaking,
    required this.errorCode,
  }) : super._();
  final String? operationalTrainNumber;
  final DateTime? startDate;
  final RailwayUndertaking? railwayUndertaking;
  final ErrorCode errorCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error &&
          runtimeType == other.runtimeType &&
          operationalTrainNumber == other.operationalTrainNumber &&
          startDate == other.startDate &&
          railwayUndertaking == other.railwayUndertaking &&
          errorCode == other.errorCode;

  @override
  int get hashCode => Object.hash(runtimeType, operationalTrainNumber, startDate, railwayUndertaking, errorCode);

  Error copyWith({
    String? operationalTrainNumber,
    DateTime? startDate,
    RailwayUndertaking? railwayUndertaking,
    ErrorCode? errorCode,
  }) {
    return Error(
      operationalTrainNumber: operationalTrainNumber ?? this.operationalTrainNumber,
      startDate: startDate ?? this.startDate,
      railwayUndertaking: railwayUndertaking ?? this.railwayUndertaking,
      errorCode: errorCode ?? this.errorCode,
    );
  }
}

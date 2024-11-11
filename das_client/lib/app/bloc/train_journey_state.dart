part of 'train_journey_cubit.dart';

@immutable
sealed class TrainJourneyState {}

final class SelectingTrainJourneyState extends TrainJourneyState {
  SelectingTrainJourneyState({this.evu, this.trainNumber, required this.date, this.errorCode});

  final String? trainNumber;
  final Evu? evu;
  final DateTime date;
  final ErrorCode? errorCode;
}

abstract class BaseTrainJourneyState extends TrainJourneyState {
  BaseTrainJourneyState(this.evu, this.trainNumber, this.date);

  final Evu evu;
  final String trainNumber;
  final DateTime date;

  @override
  String toString() {
    return '${runtimeType.toString()}(evu=$evu, trainNumber=$trainNumber, date=$date)';
  }
}

final class ConnectingState extends BaseTrainJourneyState {
  ConnectingState(super.company, super.trainNumber, super.date);
}

final class TrainJourneyLoadedState extends BaseTrainJourneyState {
  TrainJourneyLoadedState(super.company, super.trainNumber, super.date);
}



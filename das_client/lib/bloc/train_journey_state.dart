part of 'train_journey_cubit.dart';

@immutable
sealed class TrainJourneyState {}

final class SelectingTrainJourneyState extends TrainJourneyState {
  SelectingTrainJourneyState({this.company, this.trainNumber, this.errorCode});

  final String? trainNumber;
  final String? company;
  final ErrorCode? errorCode;
}

abstract class BaseTrainJourneyState extends TrainJourneyState {
  BaseTrainJourneyState(this.company, this.trainNumber, this.date);

  final String company;
  final String trainNumber;
  final DateTime date;

  @override
  String toString() {
    return '${runtimeType.toString()}(company=$company, trainNumber=$trainNumber, date=$date)';
  }
}

final class ConnectingState extends BaseTrainJourneyState {
  ConnectingState(super.company, super.trainNumber, super.date);
}

final class TrainJourneyLoadedState extends BaseTrainJourneyState {
  TrainJourneyLoadedState(super.company, super.trainNumber, super.date);
}



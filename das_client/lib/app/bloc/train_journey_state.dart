part of 'train_journey_cubit.dart';

@immutable
sealed class TrainJourneyState {}

final class SelectingTrainJourneyState extends TrainJourneyState {
  SelectingTrainJourneyState({this.ru, this.trainNumber, required this.date, this.errorCode});

  final String? trainNumber;
  final Ru? ru;
  final DateTime date;
  final ErrorCode? errorCode;
}

abstract class BaseTrainJourneyState extends TrainJourneyState {
  BaseTrainJourneyState(this.ru, this.trainNumber, this.date);

  final Ru ru;
  final String trainNumber;
  final DateTime date;

  @override
  String toString() {
    return '${runtimeType.toString()}(evu=$ru, trainNumber=$trainNumber, date=$date)';
  }
}

final class ConnectingState extends BaseTrainJourneyState {
  ConnectingState(super.ru, super.trainNumber, super.date);
}

final class TrainJourneyLoadedState extends BaseTrainJourneyState {
  TrainJourneyLoadedState(super.ru, super.trainNumber, super.date);
}



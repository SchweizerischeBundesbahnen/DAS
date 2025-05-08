part of 'train_journey_cubit.dart';

@immutable
sealed class TrainJourneyState {}

final class SelectingTrainJourneyState extends TrainJourneyState {
  SelectingTrainJourneyState({required this.date, this.ru, this.trainNumber, this.errorCode});

  final String? trainNumber;
  final Ru? ru;
  final DateTime date;
  final ErrorCode? errorCode;
}

abstract class BaseTrainJourneyState extends TrainJourneyState {
  BaseTrainJourneyState(this.trainIdentification);

  final TrainIdentification trainIdentification;

  @override
  String toString() {
    return '${runtimeType.toString()}(trainIdentification=$trainIdentification)';
  }
}

final class ConnectingState extends BaseTrainJourneyState {
  ConnectingState(super.trainIdentification);
}

final class TrainJourneyLoadedState extends BaseTrainJourneyState {
  TrainJourneyLoadedState(super.trainIdentification);
}

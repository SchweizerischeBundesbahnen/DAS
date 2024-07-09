part of 'fahrbild_cubit.dart';

@immutable
sealed class FahrbildState {}

final class SelectingFahrbildState extends FahrbildState {
  SelectingFahrbildState({this.company, this.trainNumber});

  final String? trainNumber;
  final String? company;
}

abstract class BaseFahrbildState extends FahrbildState {
  BaseFahrbildState(this.company, this.trainNumber, this.date);

  final String company;
  final String trainNumber;
  final DateTime date;
}

final class ConnectingState extends BaseFahrbildState {
  ConnectingState(super.company, super.trainNumber, super.date);
}

final class RequestingHandshakeState extends BaseFahrbildState {
  RequestingHandshakeState(super.company, super.trainNumber, super.date);
}

final class RequestingJourneyState extends BaseFahrbildState {
  RequestingJourneyState(super.company, super.trainNumber, super.date);
}

final class FahrbildLoadedState extends BaseFahrbildState {
  FahrbildLoadedState(super.company, super.trainNumber, super.date);
}

final class LoadingFailedState extends BaseFahrbildState {
  LoadingFailedState(super.company, super.trainNumber, super.date, this.errorCode);

  final ErrorCode errorCode;
}



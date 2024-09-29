part of 'fahrbild_cubit.dart';

@immutable
sealed class FahrbildState {}

final class SelectingFahrbildState extends FahrbildState {
  SelectingFahrbildState({this.company, this.trainNumber, this.errorCode});

  final String? trainNumber;
  final String? company;
  final ErrorCode? errorCode;
}

abstract class BaseFahrbildState extends FahrbildState {
  BaseFahrbildState(this.company, this.trainNumber, this.date);

  final String company;
  final String trainNumber;
  final DateTime date;

  @override
  String toString() {
    return "${runtimeType.toString()}(company=$company, trainNumber=$trainNumber, date=$date)";
  }
}

final class ConnectingState extends BaseFahrbildState {
  ConnectingState(super.company, super.trainNumber, super.date);
}

final class FahrbildLoadedState extends BaseFahrbildState {
  FahrbildLoadedState(super.company, super.trainNumber, super.date);
}



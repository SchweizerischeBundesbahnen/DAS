part of 'ux_testing_cubit.dart';

@nonProduction
@immutable
sealed class UxTestingState {}

final class UxTestingInitial extends UxTestingState {}

final class UxTestingEventReceived extends UxTestingState {
  UxTestingEventReceived({required this.event});

  final UxTesting event;
}

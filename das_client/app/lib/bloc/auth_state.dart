part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class InitialAuthState extends AuthState {}

final class Unauthenticated extends AuthState {}

final class Authenticated extends AuthState {
  Authenticated(this.user);

  final User user;
}

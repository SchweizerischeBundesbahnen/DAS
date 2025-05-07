import 'package:app/di.dart';
import 'package:auth/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(InitialAuthState());

  User? get user => (state is Authenticated) ? (state as Authenticated).user : null;

  Authenticator get _authenticator => DI.get<Authenticator>();

  Future<void> init() async {
    final isAuthenticated = await _authenticator.isAuthenticated;
    if (isAuthenticated) {
      await _emitAuthenticated();
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> login() async {
    await _authenticator.login();
    await _emitAuthenticated();
  }

  Future<void> logout() async {
    await _authenticator.logout();
    emit(Unauthenticated());
  }

  Future<void> _emitAuthenticated() async {
    final user = await _authenticator.user();
    emit(Authenticated(user));
  }
}

extension ContextBlocExtension on BuildContext {
  AuthCubit get authCubit => read<AuthCubit>();
}

import 'package:das_client/auth/authenticator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    Authenticator authenticator,
  )   :
        _authenticator = authenticator,
        super(InitialAuthState());

  final Authenticator _authenticator;

  String? get userId => (state is Authenticated) ? (state as Authenticated).userId : null;

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
    final userId = await _authenticator.userId();
    emit(Authenticated(userId));
  }
}

extension ContextBlocExtension on BuildContext {
  AuthCubit get authCubit => read<AuthCubit>();
}

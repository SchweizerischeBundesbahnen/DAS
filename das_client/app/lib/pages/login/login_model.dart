sealed class LoginModel {
  const LoginModel._({this.connectToTmsVad = false});

  factory LoginModel.loggedOut({bool connectToTmsVad}) = LoggedOut;

  factory LoginModel.loading({bool connectToTmsVad}) = Loading;

  factory LoginModel.loggedIn({bool connectToTmsVad}) = LoggedIn;

  factory LoginModel.error({required String errorMessage, bool connectToTmsVad}) = Error;

  final bool connectToTmsVad;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginModel && runtimeType == other.runtimeType && connectToTmsVad == other.connectToTmsVad;

  @override
  int get hashCode => Object.hash(runtimeType, connectToTmsVad);

  LoginModel copyWith({bool? connectToTmsVad}) {
    return switch (this) {
      final LoggedOut l => l.copyWith(connectToTmsVad: connectToTmsVad),
      final Loading l => l.copyWith(connectToTmsVad: connectToTmsVad),
      final LoggedIn l => l.copyWith(connectToTmsVad: connectToTmsVad),
      final Error e => e.copyWith(connectToTmsVad: connectToTmsVad),
    };
  }
}

class LoggedOut extends LoginModel {
  const LoggedOut({super.connectToTmsVad}) : super._();

  @override
  LoggedOut copyWith({bool? connectToTmsVad}) {
    return LoggedOut(
      connectToTmsVad: connectToTmsVad ?? this.connectToTmsVad,
    );
  }
}

class Loading extends LoginModel {
  const Loading({super.connectToTmsVad}) : super._();

  @override
  Loading copyWith({bool? connectToTmsVad}) {
    return Loading(
      connectToTmsVad: connectToTmsVad ?? this.connectToTmsVad,
    );
  }
}

class LoggedIn extends LoginModel {
  const LoggedIn({super.connectToTmsVad}) : super._();

  @override
  LoggedIn copyWith({bool? connectToTmsVad}) {
    return LoggedIn(
      connectToTmsVad: connectToTmsVad ?? this.connectToTmsVad,
    );
  }
}

class Error extends LoginModel {
  const Error({required this.errorMessage, super.connectToTmsVad}) : super._();

  final String errorMessage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || super == other || other is Error && errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(super.hashCode, errorMessage);

  @override
  Error copyWith({
    String? errorMessage,
    bool? connectToTmsVad,
  }) {
    return Error(
      errorMessage: errorMessage ?? this.errorMessage,
      connectToTmsVad: connectToTmsVad ?? this.connectToTmsVad,
    );
  }
}

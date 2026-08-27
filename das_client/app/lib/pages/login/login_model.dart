sealed class const LoginModel._({required final bool connectToTmsVad}) {
  factory loggedOut({required bool connectToTmsVad}) = LoggedOut;

  factory loading({required bool connectToTmsVad}) = Loading;

  factory loggedIn({required bool connectToTmsVad}) = LoggedIn;

  factory error({required String errorMessage, required bool connectToTmsVad}) = Error;

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

class const LoggedOut({required super.connectToTmsVad}) extends LoginModel {
  this : super._();

  @override
  LoggedOut copyWith({bool? connectToTmsVad}) {
    return LoggedOut(
      connectToTmsVad: connectToTmsVad ?? this.connectToTmsVad,
    );
  }
}

class const Loading({required super.connectToTmsVad}) extends LoginModel {
  this : super._();

  @override
  Loading copyWith({bool? connectToTmsVad}) {
    return Loading(
      connectToTmsVad: connectToTmsVad ?? this.connectToTmsVad,
    );
  }
}

class const LoggedIn({required super.connectToTmsVad}) extends LoginModel {
  this : super._();

  @override
  LoggedIn copyWith({bool? connectToTmsVad}) {
    return LoggedIn(
      connectToTmsVad: connectToTmsVad ?? this.connectToTmsVad,
    );
  }
}

class const Error({required final String errorMessage, required super.connectToTmsVad}) extends LoginModel {
  this : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || super == other && other is Error && errorMessage == other.errorMessage;

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

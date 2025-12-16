sealed class LoginModel {
  const LoginModel._();

  factory LoginModel.loggedOut() = LoggedOut;

  factory LoginModel.loading() = Loading;

  factory LoginModel.loggedIn() = LoggedIn;

  factory LoginModel.error({required String errorMessage}) = Error;

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class LoggedOut extends LoginModel {
  const LoggedOut() : super._();

  @override
  bool operator ==(Object other) => identical(this, other) || other is LoggedOut && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class Loading extends LoginModel {
  const Loading() : super._();

  @override
  bool operator ==(Object other) => identical(this, other) || other is Loading && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class LoggedIn extends LoginModel {
  const LoggedIn() : super._();

  @override
  bool operator ==(Object other) => identical(this, other) || other is LoggedIn && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class Error extends LoginModel {
  const Error({required this.errorMessage}) : super._();

  final String errorMessage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error && runtimeType == other.runtimeType && errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(runtimeType, errorMessage);
}

abstract interface class AuthorizationProvider {
  const AuthorizationProvider._();

  Future<String> call(String url);
}

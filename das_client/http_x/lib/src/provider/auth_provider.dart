abstract interface class AuthProvider {
  const AuthProvider._();

  Future<String> call({String? tokenId});
}

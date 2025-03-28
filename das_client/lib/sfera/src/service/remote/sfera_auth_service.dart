import 'dart:core';

abstract class SferaAuthService {
  const SferaAuthService._();

  Future<String?> retrieveAuthToken(String ru, String train, String role);
}

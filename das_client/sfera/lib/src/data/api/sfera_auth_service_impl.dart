import 'dart:core';

import 'package:fimber/fimber.dart';
import 'package:http_x/component.dart';
import 'package:sfera/src/data/api/endpoint/retrieve_auth_token.dart';
import 'package:sfera/src/data/api/sfera_auth_service.dart';

class SferaAuthServiceImpl implements SferaAuthService {
  SferaAuthServiceImpl({required this.httpClient, required this.tokenExchangeUrl});

  final Client httpClient;
  final String tokenExchangeUrl;

  @override
  Future<String?> retrieveAuthToken(String ru, String train, String role) async {
    final request = RetrieveAuthTokenRequest(httpClient: httpClient, tokenExchangeUrl: tokenExchangeUrl);
    try {
      final response = await request.call(ru, train, role);
      Fimber.i('Successfully retrieved sfera auth token');
      return response.token;
    } catch (e) {
      Fimber.w('Failed to retrieved sfera auth token.', ex: e);
      return null;
    }
  }
}

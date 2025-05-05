import 'dart:core';

import 'package:auth/component.dart';
import 'package:sfera/src/service/remote/sfera_auth_service.dart';
import 'package:fimber/fimber.dart';
import 'package:http/http.dart' as http;

class SferaAuthServiceImpl implements SferaAuthService {
  final Authenticator _authenticator;
  final String _tokenExchangeUrl;

  SferaAuthServiceImpl({required Authenticator authenticator, required String tokenExchangeUrl})
      : _authenticator = authenticator,
        _tokenExchangeUrl = tokenExchangeUrl;

  @override
  Future<String?> retrieveAuthToken(String ru, String train, String role) async {
    Fimber.i('Trying to fetch sfera auth token for ru=$ru train=$train role=$role...');
    final url = Uri.parse('$_tokenExchangeUrl?ru=$ru&train=$train&role=$role');

    final authToken = await _authenticator.token();

    final response = await http.get(url, headers: {
      'Authorization': '${authToken.tokenType} ${authToken.accessToken}',
    });
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      Fimber.i('Successfully retrieved sfera auth token');
      return response.body;
    } else {
      Fimber.w('Failed to retrieved sfera auth token. StatusCode=$statusCode');
      return null;
    }
  }
}

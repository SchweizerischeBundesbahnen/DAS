import 'dart:core';

import 'package:das_client/auth/authenticator.dart';
import 'package:fimber/fimber.dart';
import 'package:http/http.dart' as http;

class BackendService {
  final Authenticator _authenticator;
  final String _backendUrl;

  BackendService({required Authenticator authenticator, required String backendUrl})
      : _authenticator = authenticator,
        _backendUrl = backendUrl;

  Future<String?> retrieveSferaAuthToken(String ru, String train, String role) async {

    Fimber.i("Trying to fetch sfera auth token for ru=$ru train=$train role=$role...");
    final url = Uri.parse('$_backendUrl/customClaim/requestToken?ru=$ru&train=$train&role=$role');

    var authToken = await _authenticator.token();

    var response = await http.get(url, headers: {
      'Authorization': '${authToken.tokenType} ${authToken.accessToken.value}',
    });
    var statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      Fimber.i("Successfully retrieved sfera auth token");
      return response.body;
    } else {
      Fimber.w("Failed to retrieved sfera auth token. StatusCode=$statusCode");
      return null;
    }
  }
}

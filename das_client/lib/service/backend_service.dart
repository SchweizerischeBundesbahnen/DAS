import 'dart:convert';
import 'dart:core';

import 'package:das_client/auth/authenticator.dart';
import 'package:das_client/logging/src/log_entry.dart';
import 'package:fimber/fimber.dart';
import 'package:http/http.dart' as http;

class BackendService {
  final Authenticator _authenticator;
  final String _baseUrl;

  BackendService({required Authenticator authenticator, required String baseUrl})
      : _authenticator = authenticator,
        _baseUrl = baseUrl;

  Future<bool> sendLogs(List<LogEntry> logs) async {
    Fimber.i("Trying to send logs to backend...");
    final url = Uri.parse('$_baseUrl/api/v1/logging/logs');

    var authToken = await _authenticator.token();

    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${authToken.tokenType} ${authToken.accessToken.value}',
        },
        body: jsonEncode(logs));

    var statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      Fimber.i("Successfully sent logs to backend");
      return true;
    } else {
      Fimber.w("Failed to send logs to backend. StatusCode=$statusCode");
      return false;
    }
  }
}

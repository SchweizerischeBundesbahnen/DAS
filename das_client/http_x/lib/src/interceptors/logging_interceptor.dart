import 'dart:convert';

import 'package:fimber/fimber.dart';
import 'package:http_interceptor/models/interceptor_contract.dart';
import 'package:http_x/component.dart';

/// A HTTP interceptor that logs requests and responses.
class LoggingInterceptor implements InterceptorContract {
  const LoggingInterceptor({this.enabled = true, this.obfuscateSecrets = true});

  final bool enabled;
  final bool obfuscateSecrets;

  @override
  Future<bool> shouldInterceptRequest() async => enabled;

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final jsonString = request.toJsonString(obfuscateSecrets);
    Fimber.d('Request $jsonString');
    return request;
  }

  @override
  Future<bool> shouldInterceptResponse() async => enabled;

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    final jsonString = response.toJsonString(obfuscateSecrets);
    Fimber.d('Response $jsonString');
    return response;
  }
}

extension _BaseRequestX on BaseRequest {
  String toJsonString(bool obfuscateSecrets) {
    final json = <String, dynamic>{
      'method': method,
      'url': url.toString(),
      'content_length': contentLength,
      'persistent_connection': persistentConnection,
      'follow_redirects': followRedirects,
      'max_redirects': maxRedirects,
    };

    if (headers.isNotEmpty) {
      if (obfuscateSecrets && headers.containsKey('authorization')) {
        final headersCopy = Map.of(headers);
        headersCopy['authorization'] = '******';
        json['headers'] = headersCopy;
      } else {
        json['headers'] = headers;
      }
    }

    if (this is Request) {
      final request = this as Request;
      final bodyBytes = request.bodyBytes;
      if (bodyBytes.isNotEmpty) {
        final body = utf8.decode(bodyBytes);
        try {
          json['body'] = jsonDecode(body);
        } catch (_) {
          json['body'] = body;
        }
      }
    }

    final encoder = JsonEncoder.withIndent(' ' * 2);
    return encoder.convert(json);
  }
}

extension _BaseResponseX on BaseResponse {
  String toJsonString(bool obfuscateSecrets) {
    final json = <String, dynamic>{
      'url': request?.url.toString(),
      'status_code': statusCode,
      'reason_phrase': reasonPhrase,
      'content_length': contentLength,
      'is_redirect': isRedirect,
      'persistent connection': persistentConnection,
      'headers': headers,
    };

    if (this is Response) {
      final response = this as Response;
      final bodyBytes = response.bodyBytes;
      final contentType = headers['content-type'];
      if (bodyBytes.isNotEmpty && contentType != 'application/octet-stream') {
        // Log the body only if it's not too large (10KB).
        if (bodyBytes.lengthInBytes <= 10240) {
          final body = response.body;
          try {
            json['body'] = jsonDecode(body);
          } catch (_) {
            json['body'] = body;
          }
        } else {
          json['body'] = 'Body too large to log (>10KB)';
        }
      }
    }

    final encoder = JsonEncoder.withIndent(' ' * 2);
    return encoder.convert(json);
  }
}

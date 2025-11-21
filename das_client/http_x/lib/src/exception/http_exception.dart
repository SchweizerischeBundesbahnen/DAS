import 'dart:convert';

import 'package:http_x/component.dart';
import 'package:meta/meta.dart';

@immutable
class HttpException {
  const HttpException(this.request, this.response);

  factory HttpException.fromResponse(Response response) {
    final request = response.request as Request;
    return switch (response.statusCode) {
      // Client errors
      400 => BadRequestException(request, response),
      401 => UnauthorizedException(request, response),
      403 => ForbiddenException(request, response),
      // Server errors
      500 => InternalServerErrorException(request, response),
      501 => NotImplementedException(request, response),
      502 => BadGatewayException(request, response),
      503 => ServiceUnavailableException(request, response),
      // Default
      _ => HttpException(request, response),
    };
  }

  final Request request;
  final Response response;

  /// The URL to which the request was sent.
  String get url => request.url.toString();

  /// The HTTP status code of the response.
  int get statusCode => response.statusCode;

  /// The HTTP status label of the response.
  String get statusLabel => statusCode.toString();

  /// Converts this HTTP exception to json.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'request': request.toJson(), 'response': response.toJson()};
  }

  /// Converts this HTTP exception to a json string.
  String toJsonString({bool pretty = false}) {
    final json = toJson();
    final encoder = JsonEncoder.withIndent(pretty ? ' ' * 2 : null);
    return encoder.convert(json);
  }

  @override
  String toString() {
    return 'HttpException{label: $statusLabel, status: $statusCode, url: $url, body: ${response.body}}';
  }
}

extension RequestToJsonX on Request {
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'method': method,
      'url': url.toString(),
      'content_length': contentLength,
      'persistent connection': persistentConnection,
      'follow_redirects': followRedirects,
      'max_redirects': maxRedirects,
      'headers': headers,
      'encoding': encoding.name,
    };
    try {
      json['body'] = jsonDecode(body);
    } catch (_) {
      json['body'] = body;
    }
    return json;
  }
}

extension ResponseToJsonX on Response {
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'status_code': statusCode,
      'reason_phrase': reasonPhrase,
      'content_length': contentLength,
      'is_redirect': isRedirect,
      'persistent connection': persistentConnection,
      'headers': headers,
    };
    try {
      json['body'] = jsonDecode(body);
    } catch (_) {
      json['body'] = body;
    }
    return json;
  }
}

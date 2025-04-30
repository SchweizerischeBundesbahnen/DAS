import 'package:http_x/component.dart';

/// **502 Bad Gateway**
///
/// The 502 (Bad Gateway) status code indicates that the server, while acting
/// as a gateway or proxy, received an invalid response from an inbound server
/// it accessed while attempting to fulfill the request.
///
/// - https://www.rfc-editor.org/rfc/rfc9110.html#name-502-bad-gateway
/// - https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#502
class BadGatewayException extends HttpException {
  const BadGatewayException(super.request, super.response);

  @override
  String get statusLabel => '502 Bad Gateway';

  @override
  String toString() {
    final jsonString = toJsonString(pretty: true);
    return '$statusLabel $jsonString';
  }
}

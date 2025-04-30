import 'package:http_x/component.dart';

/// **500 Internal Server Error**
///
/// The 500 (Internal Server Error) status code indicates that the server
/// encountered an unexpected condition that prevented it from fulfilling the
/// request.
///
/// - https://www.rfc-editor.org/rfc/rfc9110.html#name-500-internal-server-error
/// - https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#500
class InternalServerErrorException extends HttpException {
  const InternalServerErrorException(super.request, super.response);

  @override
  String get statusLabel => '500 Internal Server Error';

  @override
  String toString() {
    final jsonString = toJsonString(pretty: true);
    return '$statusLabel $jsonString';
  }
}

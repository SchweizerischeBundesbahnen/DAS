import 'package:http_x/component.dart';

/// **400 Bad Request**
///
/// The 400 (Bad Request) status code indicates that the server cannot or will
/// not process the request due to something that is perceived to be a client
/// error (e.g., malformed request syntax, invalid request message framing, or
/// deceptive request routing).
///
/// - https://www.rfc-editor.org/rfc/rfc9110.html#name-400-bad-request
/// - https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#400
class BadRequestException extends HttpException {
  const BadRequestException(super.request, super.response);

  @override
  String get statusLabel => '400 Bad Request';
}

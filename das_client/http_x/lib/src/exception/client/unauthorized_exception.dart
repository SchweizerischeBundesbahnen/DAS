import 'package:http_x/component.dart';

/// **401 Unauthorized**
///
/// The 401 (Unauthorized) status code indicates that the request has not been
/// applied because it lacks valid authentication credentials for the target
/// resource.
///
/// If the request included authentication credentials, then the 401 response
/// indicates that authorization has been refused for those credentials. The
/// user agent MAY repeat the request with a new or replaced Authorization
/// header field
///
/// - https://www.rfc-editor.org/rfc/rfc9110.html#name-401-unauthorized
/// - https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#401
class UnauthorizedException extends HttpException {
  const UnauthorizedException(super.request, super.response);

  @override
  String get statusLabel => '401 Unauthorized';

  @override
  String toString() {
    final jsonString = toJsonString(pretty: true);
    return '$statusLabel $jsonString';
  }
}

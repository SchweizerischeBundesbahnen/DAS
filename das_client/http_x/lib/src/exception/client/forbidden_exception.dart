import 'package:http_x/component.dart';

/// **403 Forbidden**
///
/// The request contained valid data and was understood by the server, but the
/// server is refusing action. This may be due to the user not having the
/// necessary permissions for a resource or needing an account of some sort, or
/// attempting a prohibited action (e.g. creating a duplicate record where only
/// one is allowed). This code is also typically used if the request provided
/// authentication by answering the WWW-Authenticate header field challenge,
/// but the server did not accept that authentication. The request should not
/// be repeated.
///
/// - https://www.rfc-editor.org/rfc/rfc9110.html#name-403-forbidden
/// - https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#403
class ForbiddenException extends HttpException {
  const ForbiddenException(super.request, super.response);

  @override
  String get statusLabel => '403 Forbidden';

  @override
  String toString() {
    final jsonString = toJsonString(pretty: true);
    return '$statusLabel $jsonString';
  }
}

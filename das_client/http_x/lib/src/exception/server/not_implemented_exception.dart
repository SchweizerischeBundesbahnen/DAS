import 'package:http_x/component.dart';

/// **501 Not Implemented**
///
/// The 501 (Not Implemented) status code indicates that the server does not
/// support the functionality required to fulfill the request. This is the
/// appropriate response when the server does not recognize the request method
/// and is not capable of supporting it for any resource.
///
/// - https://www.rfc-editor.org/rfc/rfc9110.html#name-501-not-implemented
/// - https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#501
class NotImplementedException extends HttpException {
  const NotImplementedException(super.request, super.response);

  @override
  String get statusLabel => '501 Not Implemented';
}

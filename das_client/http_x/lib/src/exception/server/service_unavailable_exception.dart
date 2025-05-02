import 'package:http_x/component.dart';

/// **503 Service Unavailable**
///
/// The 503 (Service Unavailable) status code indicates that the server is
/// currently unable to handle the request due to a temporary overload or
/// scheduled maintenance, which will likely be alleviated after some delay.
///
/// - https://www.rfc-editor.org/rfc/rfc9110.html#name-503-service-unavailable
/// - https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#503
class ServiceUnavailableException extends HttpException {
  const ServiceUnavailableException(super.request, super.response);

  @override
  String get statusLabel => '503 Service Unavailable';
}

import 'package:customer_oriented_departure/src/api/confirm/confirm_request.dart';
import 'package:customer_oriented_departure/src/api/customer_oriented_departure_api_service.dart';
import 'package:customer_oriented_departure/src/api/subscribe/subscribe_request.dart';
import 'package:http_x/component.dart';

class CustomerOrientedDepartureApiServiceImpl({
  required final String baseUrl,
  required final Client httpClient,
}) implements CustomerOrientedDepartureApiService {
  @override
  SubscribeRequest get subscribe =>
      SubscribeRequest(requestType: SubscribeRequestType.register, httpClient: httpClient, baseUrl: baseUrl);

  @override
  SubscribeRequest get unsubscribe =>
      SubscribeRequest(requestType: SubscribeRequestType.deregister, httpClient: httpClient, baseUrl: baseUrl);

  @override
  ConfirmRequest get confirm => ConfirmRequest(httpClient: httpClient, baseUrl: baseUrl);
}

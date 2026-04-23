import 'package:customer_oriented_departure/src/api/confirm/request.dart';
import 'package:customer_oriented_departure/src/api/customer_oriented_departure_api_service.dart';
import 'package:customer_oriented_departure/src/api/subscribe/request.dart';
import 'package:http_x/component.dart';

class CustomerOrientedDepartureApiServiceImpl implements CustomerOrientedDepartureApiService {
  CustomerOrientedDepartureApiServiceImpl({required this.baseUrl, required this.httpClient});

  final String baseUrl;
  final Client httpClient;

  @override
  SubscribeRequest get subscribe => SubscribeRequest(httpClient: httpClient, baseUrl: baseUrl);

  @override
  ConfirmRequest get confirm => ConfirmRequest(httpClient: httpClient, baseUrl: baseUrl);
}

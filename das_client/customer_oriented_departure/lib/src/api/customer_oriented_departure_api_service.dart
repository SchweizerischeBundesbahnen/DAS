import 'package:customer_oriented_departure/src/api/confirm/request.dart';
import 'package:customer_oriented_departure/src/api/subscribe/request.dart';

abstract class CustomerOrientedDepartureApiService {
  SubscribeRequest get subscribe;

  ConfirmRequest get confirm;
}

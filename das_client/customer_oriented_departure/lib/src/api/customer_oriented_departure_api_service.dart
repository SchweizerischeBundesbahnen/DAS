import 'package:customer_oriented_departure/src/api/confirm/confirm_request.dart';
import 'package:customer_oriented_departure/src/api/subscribe/subscribe_request.dart';

abstract class CustomerOrientedDepartureApiService {
  SubscribeRequest get unsubscribe;

  SubscribeRequest get subscribe;

  ConfirmRequest get confirm;
}

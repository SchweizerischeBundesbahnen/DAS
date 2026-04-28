import 'package:customer_oriented_departure/src/api/customer_oriented_departure_api_service_impl.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/firebase_messaging_service.dart';
import 'package:customer_oriented_departure/src/repository/customer_oriented_departure_repository.dart';
import 'package:customer_oriented_departure/src/repository/customer_oriented_departure_repository_impl.dart';
import 'package:http_x/component.dart';

export 'package:customer_oriented_departure/src/model/customer_oriented_departure_status.dart';
export 'package:customer_oriented_departure/src/repository/customer_oriented_departure_repository.dart';

class CustomerOrientedDepartureComponent {
  const CustomerOrientedDepartureComponent._();

  static CustomerOrientedDepartureRepository createRepository({
    required String baseUrl,
    required Client client,
    required String deviceId,
  }) {
    return CustomerOrientedDepartureRepositoryImpl(
      apiService: CustomerOrientedDepartureApiServiceImpl(baseUrl: baseUrl, httpClient: client),
      messagingService: FirebaseMessagingService(),
      deviceId: deviceId,
    );
  }
}

import 'package:customer_oriented_departure/component.dart';
import 'package:customer_oriented_departure/src/api/customer_oriented_departure_api_service.dart';
import 'package:customer_oriented_departure/src/api/subscribe/request.dart';
import 'package:logging/logging.dart';

final _log = Logger('CustomerOrientedDepartureRepositoryImpl');

class CustomerOrientedDepartureRepositoryImpl implements CustomerOrientedDepartureRepository {
  CustomerOrientedDepartureRepositoryImpl({
    required this.apiService,
  });

  final CustomerOrientedDepartureApiService apiService;

  @override
  Future<bool> subscribe({
    required String evu,
    required String trainNumber,
    required String pushToken,
    required String deviceId,
    required String messageId,
    required DateTime expiresAt,
    required bool isDriver,
  }) async {
    try {
      await apiService.subscribe(
        type: SubscribeRequestType.register,
        evu: evu,
        trainNumber: trainNumber,
        pushToken: pushToken,
        deviceId: deviceId,
        messageId: messageId,
        expiresAt: expiresAt,
        isDriver: isDriver,
      );
      _log.info('Successfully requested subscribe for $evu $trainNumber.');
      return true;
    } catch (e) {
      _log.severe('Error while requesting subscribe for $evu $trainNumber', e);
      return false;
    }
  }

  @override
  Future<bool> unsubscribe({
    required String evu,
    required String trainNumber,
    required String pushToken,
    required String deviceId,
    required String messageId,
    required DateTime expiresAt,
    required bool isDriver,
  }) async {
    try {
      await apiService.subscribe(
        type: SubscribeRequestType.deregister,
        evu: evu,
        trainNumber: trainNumber,
        pushToken: pushToken,
        deviceId: deviceId,
        messageId: messageId,
        expiresAt: expiresAt,
        isDriver: isDriver,
      );
      _log.info('Successfully requested unsubscribe for $evu $trainNumber.');
      return true;
    } catch (e) {
      _log.severe('Error while requesting unsubscribe for $evu $trainNumber', e);
      return false;
    }
  }
}

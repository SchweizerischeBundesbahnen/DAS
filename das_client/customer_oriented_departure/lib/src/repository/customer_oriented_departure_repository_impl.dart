import 'package:customer_oriented_departure/component.dart';
import 'package:customer_oriented_departure/src/api/customer_oriented_departure_api_service.dart';
import 'package:customer_oriented_departure/src/api/subscribe/request.dart';
import 'package:customer_oriented_departure/src/messaging/messaging_service.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

final _log = Logger('CustomerOrientedDepartureRepositoryImpl');

class CustomerOrientedDepartureRepositoryImpl implements CustomerOrientedDepartureRepository {
  CustomerOrientedDepartureRepositoryImpl({
    required this.apiService,
    required this.messagingService,
  });

  final CustomerOrientedDepartureApiService apiService;
  final MessagingService messagingService;

  @override
  Future<bool> subscribe({
    required String evu,
    required String trainNumber,
    required String deviceId,
    required DateTime journeyEndTime,
    required bool isDriver,
  }) async {
    final pushToken = messagingService.tokenValue;
    if (pushToken == null) {
      _log.severe('No push token available for subscribing to $evu $trainNumber');
      return false;
    }

    try {
      await apiService.subscribe(
        type: SubscribeRequestType.register,
        evu: evu,
        trainNumber: trainNumber,
        pushToken: pushToken,
        deviceId: deviceId,
        messageId: Uuid().v4(),
        expiresAt: journeyEndTime,
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
    required String deviceId,
    required DateTime journeyEndTime,
    required bool isDriver,
  }) async {
    final pushToken = messagingService.tokenValue;
    if (pushToken == null) {
      _log.severe('No push token available for subscribing to $evu $trainNumber');
      return false;
    }

    try {
      await apiService.subscribe(
        type: SubscribeRequestType.deregister,
        evu: evu,
        trainNumber: trainNumber,
        pushToken: pushToken,
        deviceId: deviceId,
        messageId: Uuid().v4(),
        expiresAt: journeyEndTime,
        isDriver: isDriver,
      );
      _log.info('Successfully requested unsubscribe for $evu $trainNumber.');
      return true;
    } catch (e) {
      _log.severe('Error while requesting unsubscribe for $evu $trainNumber', e);
      return false;
    }
  }

  @override
  Stream<CustomerOrientedDepartureStatus> get status => messagingService.message
      .mapTo((message) => CustomerOrientedDepartureStatus.from(message.status))
      .whereType<CustomerOrientedDepartureStatus>();
}

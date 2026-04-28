import 'dart:async';

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
  }) {
    _init();
  }

  final CustomerOrientedDepartureApiService apiService;
  final MessagingService messagingService;

  _Subscription? _pendingOrOpenSubscription;
  StreamSubscription? _tokenSubscription;

  void _init() {
    _tokenSubscription = messagingService.token.listen((token) {
      if (token != null && _pendingOrOpenSubscription != null && _pendingOrOpenSubscription!.pushToken != token) {
        _log.info('Received new push token for open/pending subscription');
        _sendRegisterRequest(subscription: _pendingOrOpenSubscription!.withToken(token: token));
      }
    });
  }

  @override
  Future<bool> subscribe({
    required String evu,
    required String trainNumber,
    required String deviceId,
    required DateTime journeyEndTime,
    required bool isDriver,
  }) async {
    final subscription = _Subscription(
      evu: evu,
      trainNumber: trainNumber,
      deviceId: deviceId,
      journeyEndTime: journeyEndTime,
      isDriver: isDriver,
      messageId: Uuid().v4(),
      pushToken: messagingService.tokenValue,
    );

    if (subscription == _pendingOrOpenSubscription) {
      _log.info('Already subscribed to $evu $trainNumber with given token');
      return true;
    } else if (_pendingOrOpenSubscription != null) {
      _log.info(
        'There is another open subscription for ${_pendingOrOpenSubscription!.evu} ${_pendingOrOpenSubscription!.trainNumber}.',
      );
      await _sendDeregisterRequest(subscription: _pendingOrOpenSubscription!);
    }

    if (subscription.pushToken == null) {
      _log.severe(
        'No push token available for subscribing to $evu $trainNumber. Will try subscribing when token is refreshed.',
      );
      _pendingOrOpenSubscription = subscription;
      return false;
    }

    return _sendRegisterRequest(subscription: subscription);
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
      _pendingOrOpenSubscription = null;
      _log.info('Successfully requested unsubscribe for $evu $trainNumber.');
      return true;
    } catch (e) {
      _log.severe('Error while requesting unsubscribe for $evu $trainNumber', e);
      return false;
    }
  }

  @override
  Stream<CustomerOrientedDepartureStatus> get status => messagingService.message
      .map((message) => CustomerOrientedDepartureStatus.from(message.status))
      .whereType<CustomerOrientedDepartureStatus>();

  @override
  void dispose() {
    _tokenSubscription?.cancel();
    _tokenSubscription = null;
  }

  Future<bool> _sendDeregisterRequest({required _Subscription subscription}) async {
    return unsubscribe(
      evu: subscription.evu,
      trainNumber: subscription.trainNumber,
      deviceId: subscription.deviceId,
      journeyEndTime: subscription.journeyEndTime,
      isDriver: subscription.isDriver,
    );
  }

  Future<bool> _sendRegisterRequest({required _Subscription subscription}) async {
    final evu = subscription.evu;
    final trainNumber = subscription.trainNumber;
    try {
      await apiService.subscribe(
        type: SubscribeRequestType.register,
        evu: evu,
        trainNumber: trainNumber,
        pushToken: subscription.pushToken!,
        deviceId: subscription.deviceId,
        messageId: subscription.messageId,
        expiresAt: subscription.journeyEndTime,
        isDriver: subscription.isDriver,
      );
      _log.info('Successfully requested subscribe for $evu $trainNumber.');
      return true;
    } catch (e) {
      _log.severe('Error while requesting subscribe for $evu $trainNumber', e);
      return false;
    }
  }
}

class _Subscription {
  _Subscription({
    required this.evu,
    required this.trainNumber,
    required this.deviceId,
    required this.journeyEndTime,
    required this.messageId,
    required this.isDriver,
    this.pushToken,
  });

  final String evu;
  final String trainNumber;
  final String deviceId;
  final DateTime journeyEndTime;
  final bool isDriver;
  final String? pushToken;

  // should not be part of equality check
  final String messageId;

  _Subscription withToken({required String token}) => _Subscription(
    evu: evu,
    trainNumber: trainNumber,
    deviceId: deviceId,
    journeyEndTime: journeyEndTime,
    isDriver: isDriver,
    messageId: messageId,
    pushToken: token,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Subscription &&
          runtimeType == other.runtimeType &&
          evu == other.evu &&
          trainNumber == other.trainNumber &&
          deviceId == other.deviceId &&
          journeyEndTime == other.journeyEndTime &&
          isDriver == other.isDriver &&
          pushToken == other.pushToken;

  @override
  int get hashCode => Object.hash(evu, trainNumber, deviceId, journeyEndTime, isDriver, pushToken);
}

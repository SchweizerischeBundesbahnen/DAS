import 'dart:async';

import 'package:customer_oriented_departure/component.dart';
import 'package:customer_oriented_departure/src/api/customer_oriented_departure_api_service.dart';
import 'package:customer_oriented_departure/src/api/subscribe/request.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/dto/train_status_message_dto.dart';
import 'package:customer_oriented_departure/src/messaging/messaging_service.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

final _log = Logger('CustomerOrientedDepartureRepositoryImpl');

// todo: check with GEMS
final _defaultExpireDuration = Duration(hours: 2);

class CustomerOrientedDepartureRepositoryImpl implements CustomerOrientedDepartureRepository {
  CustomerOrientedDepartureRepositoryImpl({
    required this.apiService,
    required this.messagingService,
    required this.deviceId,
  }) {
    _init();
  }

  final CustomerOrientedDepartureApiService apiService;
  final MessagingService messagingService;
  final String deviceId;

  final _rxCustomerOrientedDeparture = BehaviorSubject<CustomerOrientedDeparture>();
  final _subscriptions = <StreamSubscription>[];

  _Subscription? _pendingOrOpenSubscription;

  void _init() {
    _initToken();
    _initMessages();
  }

  @override
  Future<bool> subscribe({
    required String evu,
    required String trainNumber,
    required DateTime? journeyEndTime,
    required bool isDriver,
  }) async {
    final expiresAt = journeyEndTime ?? DateTime.now().add(_defaultExpireDuration);
    final subscription = _Subscription(
      evu: evu,
      trainNumber: trainNumber,
      expiresAt: expiresAt,
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
      await unsubscribe();
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
  Future<bool> unsubscribe() async {
    if (_pendingOrOpenSubscription == null) {
      _log.severe('No open subscription for unsubscribing.');
      return true;
    }

    final evu = _pendingOrOpenSubscription!.evu;
    final trainNumber = _pendingOrOpenSubscription!.trainNumber;
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
        expiresAt: _pendingOrOpenSubscription!.expiresAt,
        isDriver: _pendingOrOpenSubscription!.isDriver,
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
  Stream<CustomerOrientedDeparture> get customerOrientedDeparture => _rxCustomerOrientedDeparture.stream;

  @override
  void dispose() {
    _rxCustomerOrientedDeparture.close();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
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
        deviceId: deviceId,
        messageId: subscription.messageId,
        expiresAt: subscription.expiresAt,
        isDriver: subscription.isDriver,
      );
      _log.info('Successfully requested subscribe for $evu $trainNumber.');
      return true;
    } catch (e) {
      _log.severe('Error while requesting subscribe for $evu $trainNumber', e);
      return false;
    }
  }

  void _initToken() {
    final sub = messagingService.token.listen((token) {
      if (token != null && _pendingOrOpenSubscription != null && _pendingOrOpenSubscription!.pushToken != token) {
        _log.info('Received new push token for open/pending subscription');
        _sendRegisterRequest(subscription: _pendingOrOpenSubscription!.withToken(token: token));
      }
    });
    _subscriptions.add(sub);
  }

  void _initMessages() {
    final sub = messagingService.message.listen((message) {
      if (message is TrainStatusMessageDto) {
        _handleTrainStatusMessage(message);
      }
    });
    _subscriptions.add(sub);
  }

  void _handleTrainStatusMessage(TrainStatusMessageDto message) {
    final status = CustomerOrientedDepartureStatus.from(message.status);
    if (status == null) {
      _log.warning('Received message with unknown status: ${message.status}');
    } else {
      final customerOrientedDeparture = CustomerOrientedDeparture(trainNumber: message.zugnr, status: status);
      _rxCustomerOrientedDeparture.add(customerOrientedDeparture);
      _confirmMessageReceived(message.messageId);
    }
  }

  Future<void> _confirmMessageReceived(String messageId) async {
    try {
      await apiService.confirm(deviceId: deviceId, messageId: messageId);
      _log.fine('Successfully sent confirm for message $messageId.');
    } catch (e) {
      _log.severe('Error while sending confirm for message $messageId', e);
    }
  }
}

class _Subscription {
  _Subscription({
    required this.evu,
    required this.trainNumber,
    required this.expiresAt,
    required this.messageId,
    required this.isDriver,
    this.pushToken,
  });

  final String evu;
  final String trainNumber;
  final DateTime expiresAt;
  final bool isDriver;
  final String? pushToken;

  // should not be part of equality check
  final String messageId;

  _Subscription withToken({required String token}) => _Subscription(
    evu: evu,
    trainNumber: trainNumber,
    expiresAt: expiresAt,
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
          expiresAt == other.expiresAt &&
          isDriver == other.isDriver &&
          pushToken == other.pushToken;

  @override
  int get hashCode => Object.hash(evu, trainNumber, expiresAt, isDriver, pushToken);
}

import 'dart:async';
import 'dart:math';

import 'package:customer_oriented_departure/component.dart';
import 'package:customer_oriented_departure/src/api/customer_oriented_departure_api_service.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/dto/base_message_dto.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/dto/train_status_message_dto.dart';
import 'package:customer_oriented_departure/src/messaging/messaging_service.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

final _log = Logger('CustomerOrientedDepartureRepositoryImpl');

class CustomerOrientedDepartureRepositoryImpl implements CustomerOrientedDepartureRepository {
  /// buffer duration used on journey end time for possible delays
  static const expireAtBuffer = Duration(hours: 1);

  /// default expire at time for subscription. This value is currently used by LEA in production.
  static const defaultExpireAtDuration = Duration(hours: 6);

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
  Timer? _subscriptionRetryTimer;
  int _subscriptionRetryAttempt = 0;

  @override
  Future<bool> subscribe({
    required String evu,
    required String trainNumber,
    required DateTime? journeyEndTime,
    required bool isDriver,
  }) async {
    final subscription = _Subscription(
      evu: evu,
      trainNumber: trainNumber,
      expiresAt: _calculateExpiresAt(journeyEndTime),
      isDriver: isDriver,
      messageId: Uuid().v4(),
      pushToken: messagingService.tokenValue,
    );

    if (_pendingOrOpenSubscription != null && !subscription.hasChanged(_pendingOrOpenSubscription!)) {
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

    _pendingOrOpenSubscription = subscription;

    return _sendSubscribeRequest(subscription: subscription);
  }

  @override
  Future<bool> unsubscribe() async {
    if (_pendingOrOpenSubscription == null) {
      _log.severe('No open subscription for unsubscribing.');
      return true;
    }

    _cancelSubscriptionRetry();

    final evu = _pendingOrOpenSubscription!.evu;
    final trainNumber = _pendingOrOpenSubscription!.trainNumber;
    final pushToken = messagingService.tokenValue;
    if (pushToken == null) {
      _log.severe('No push token available for subscribing to $evu $trainNumber');
      return false;
    }

    try {
      await apiService.unsubscribe(
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
  void requestLatestStatus() {
    messagingService.replayMessages();
  }

  @override
  void dispose() {
    _subscriptionRetryTimer?.cancel();
    _subscriptionRetryTimer = null;
    _rxCustomerOrientedDeparture.close();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
  }

  void _init() {
    _initTokenSubscription();
    _initMessagesSubscription();
  }

  void _initTokenSubscription() {
    final sub = messagingService.token.listen((token) {
      if (token != null && _pendingOrOpenSubscription != null && _pendingOrOpenSubscription!.pushToken != token) {
        _log.fine('Received new push token for open/pending subscription');
        _pendingOrOpenSubscription = _pendingOrOpenSubscription!.withToken(token: token);
        _sendSubscribeRequest(subscription: _pendingOrOpenSubscription!);
      }
    });
    _subscriptions.add(sub);
  }

  void _initMessagesSubscription() {
    final sub = messagingService.message.listen((message) {
      if (message is TrainStatusMessageDto) {
        _handleTrainStatusMessage(message);
      } else {
        _handleSubscriptionConfirmation(message);
      }
    });
    _subscriptions.add(sub);
  }

  DateTime _calculateExpiresAt(DateTime? journeyEndTime) {
    if (journeyEndTime != null) {
      return journeyEndTime.add(expireAtBuffer);
    }
    return DateTime.now().add(defaultExpireAtDuration);
  }

  Future<bool> _sendSubscribeRequest({required _Subscription subscription}) async {
    final evu = subscription.evu; // TODO: check with GEMS if need to change to hardcoded SBB
    final trainNumber = subscription.trainNumber;

    try {
      await apiService.subscribe(
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
    } finally {
      _scheduleSubscriptionRetry(subscription);
    }
  }

  void _scheduleSubscriptionRetry(_Subscription subscription) {
    // 10 * 2^attempt for exponential backoff. Capped at 2^7 (~21min)
    final delaySeconds = 10 * (1 << min(_subscriptionRetryAttempt, 7));

    _log.fine(
      'Scheduling subscription retry for messageId: ${subscription.messageId}, attempt: ${_subscriptionRetryAttempt + 1}, delay: ${delaySeconds}s',
    );

    _subscriptionRetryTimer?.cancel();
    _subscriptionRetryTimer = Timer(Duration(seconds: delaySeconds), () async {
      if (_pendingOrOpenSubscription?.messageId == subscription.messageId) {
        _subscriptionRetryAttempt++;
        await _sendSubscribeRequest(subscription: _pendingOrOpenSubscription!);
      }
    });
  }

  void _cancelSubscriptionRetry() {
    _subscriptionRetryTimer?.cancel();
    _subscriptionRetryTimer = null;
    _subscriptionRetryAttempt = 0;
  }

  void _handleSubscriptionConfirmation(BaseMessageDto message) {
    if (_pendingOrOpenSubscription?.messageId == message.messageId) {
      _log.info('Subscription confirmed for messageId: ${message.messageId}');
      _cancelSubscriptionRetry();
    }
  }

  void _handleTrainStatusMessage(TrainStatusMessageDto message) {
    final status = CustomerOrientedDepartureStatus.from(message.status);
    if (status == null) {
      _log.warning('Received message with unknown status: ${message.status}');
    } else {
      final customerOrientedDeparture = CustomerOrientedDeparture(trainNumber: message.zugnr, status: status);
      _rxCustomerOrientedDeparture.add(customerOrientedDeparture);
      _sendConfirmMessageRequest(message.messageId);
    }
  }

  Future<void> _sendConfirmMessageRequest(String messageId) async {
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
  final String messageId;

  _Subscription withToken({required String token}) => _Subscription(
    evu: evu,
    trainNumber: trainNumber,
    expiresAt: expiresAt,
    isDriver: isDriver,
    messageId: messageId,
    pushToken: token,
  );

  bool hasChanged(_Subscription other) {
    return evu != other.evu ||
        trainNumber != other.trainNumber ||
        isDriver != other.isDriver ||
        pushToken != other.pushToken;
  }
}

import 'dart:async';

import 'package:customer_oriented_departure/src/messaging/firebase/dto/base_message_dto.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/dto/train_status_message_dto.dart';
import 'package:customer_oriented_departure/src/messaging/firebase/local_message_storage.dart';
import 'package:customer_oriented_departure/src/messaging/messaging_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('FirebaseMessagingService');

// TODO: Add test for local storage handling
class FirebaseMessagingService implements MessagingService {
  FirebaseMessagingService() {
    _init();
  }

  final _rxToken = BehaviorSubject<String?>();
  final _rxMessage = BehaviorSubject<BaseMessageDto>();
  final _subscriptions = <StreamSubscription>[];

  @override
  Stream<String?> get token => _rxToken.stream;

  @override
  String? get tokenValue => _rxToken.value;

  @override
  Stream<BaseMessageDto> get message => _rxMessage.stream;

  @override
  Future<void> replayMessages() async {
    _log.fine('Replaying messages from local storage');
    final latestMessages = await LocalMessageStorage.getLatestMessages();
    for (final message in latestMessages) {
      _rxMessage.add(message);
    }

    await LocalMessageStorage.clear();
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
  }

  Future<void> _init() async {
    await LocalMessageStorage.clear();
    await _initRxToken();
    await _initRxMessage();
  }

  Future<void> _initRxToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    _rxToken.add(token);

    final sub = FirebaseMessaging.instance.onTokenRefresh.listen(_rxToken.add, onError: _rxToken.addError);

    _subscriptions.add(sub);
  }

  Future<void> _initRxMessage() async {
    final messageStreams = [
      FirebaseMessaging.onMessage,
      FirebaseMessaging.onMessageOpenedApp,
    ];

    final stream = MergeStream(messageStreams).map(
      (message) {
        _log.info('Remote message received');
        return _tryParseRemoteMessage(message);
      },
    ).whereNotNull();

    final sub = stream.listen(_rxMessage.add, onError: _rxMessage.addError);
    _subscriptions.add(sub);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage remoteMessage) async {
  _log.info('Remote message received in background.');
  final message = _tryParseRemoteMessage(remoteMessage);
  if (message != null) {
    await LocalMessageStorage.addMessage(message);
  }
}

BaseMessageDto? _tryParseRemoteMessage(RemoteMessage message) {
  try {
    if (message.data.containsKey('status')) {
      return TrainStatusMessageDto.fromJson(message.data);
    }
    return BaseMessageDto.fromJson(message.data);
  } catch (e) {
    _log.severe('Failed to parse remote message ${message.messageId} with data: ${message.data}', e);
    return null;
  }
}

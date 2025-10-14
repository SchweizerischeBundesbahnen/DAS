import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:connectivity_x/component.dart';
import 'package:logging/logging.dart';
import 'package:mqtt/src/mqtt_client_connector.dart';
import 'package:mqtt/src/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('MqttServiceImpl');

class MqttServiceImpl implements MqttService {
  static const _keepAlivePeriodSeconds = 15;

  MqttServiceImpl({
    required String mqttUrl,
    required MqttClientConnector mqttClientConnector,
    required this.deviceId,
    required this.prefix,
  }) : _mqttUrl = mqttUrl,
       _mqttClientConnector = mqttClientConnector {
    _init();
  }

  final _connectivityManager = ConnectivityComponent.connectivityManager();
  StreamSubscription? _connectivitySubscription;
  var _connected = false;

  final String _mqttUrl;
  final MqttClientConnector _mqttClientConnector;
  final String prefix;

  late MqttServerClient _client;
  late String deviceId;

  StreamSubscription? _updateSubscription;

  final _messageSubject = BehaviorSubject<String>();

  @override
  Stream<String> get messageStream => _messageSubject.stream;

  void _init() async {
    _client = MqttServerClient.withPort(_mqttUrl, deviceId, 8443);
    _client.useWebSocket = true;
    _client.autoReconnect = true;
    _client.resubscribeOnAutoReconnect = true;
    _client.keepAlivePeriod = _keepAlivePeriodSeconds;
    _logClientChanges();

    _connectivitySubscription = _connectivityManager.onConnectivityChanged.distinct().listen((connected) {
      if (_connected && connected) {
        _log.info('Reconnecting to MQTT broker due to connectivity change');
        _client.doAutoReconnect(force: true);
      }
    });
  }

  void _logClientChanges() {
    _client.onConnected = () {
      _log.fine('Connected to MQTT broker');
    };
    _client.onAutoReconnect = () {
      _log.fine('Reconnecting to MQTT broker');
    };
    _client.onAutoReconnected = () {
      _log.fine('Reconnected to MQTT broker');
    };
    _client.onDisconnected = () {
      _log.fine('Disconnected from MQTT broker');
    };
  }

  @override
  void disconnect() {
    _log.info('Disconnecting from MQTT broker');
    _connected = false;
    _client.disconnect();
  }

  @override
  Future<bool> connect(String company, String train) async {
    if (_client.connectionStatus?.state != MqttConnectionState.disconnected) {
      disconnect();
    }
    if (await _mqttClientConnector.connect(_client, company, train)) {
      _client.subscribe('${prefix}90940/2/event/$company/$train', MqttQos.exactlyOnce);
      _client.subscribe('${prefix}90940/2/event/$company/$train/$deviceId', MqttQos.exactlyOnce);
      _client.subscribe('${prefix}90940/2/G2B/$company/$train/$deviceId', MqttQos.exactlyOnce);
      _log.info("Subscribed to topic with prefix='$prefix'...");
      _startUpdateListener();
      _connected = true;
      return true;
    }

    return false;
  }

  @override
  bool publishMessage(String company, String train, String message) {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      final topic = '${prefix}90940/2/B2G/$company/$train/$deviceId';

      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);

      _log.finer('Published MQTT message: topic=$topic message=$message');
      return true;
    } else {
      _log.warning('Failed to publish MQTT message because it is not connected');
      return false;
    }
  }

  void _startUpdateListener() {
    _updateSubscription?.cancel();
    _updateSubscription = _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>>? messageList) {
      if (messageList != null) {
        for (final message in messageList) {
          _log.finer(
            'Received mqtt message with type=${message.runtimeType.toString()} payload=${message.payload.toString()}',
          );

          if (message.payload is MqttPublishMessage) {
            final recMess = message.payload as MqttPublishMessage;
            final decodedMessage = utf8.decode(recMess.payload.message);
            _log.finer('Decoded mqtt message: $decodedMessage');
            _messageSubject.add(decodedMessage);
          } else {
            _log.warning('Type ${message.payload.runtimeType.toString()} parsing not implemented');
          }
        }
      } else {
        _log.warning('received mqtt update with messageList=null');
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _updateSubscription?.cancel();
    _messageSubject.close();
    _client.disconnect();
  }
}

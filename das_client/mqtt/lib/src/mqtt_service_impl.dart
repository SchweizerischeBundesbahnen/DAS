import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:logging/logging.dart';
import 'package:mqtt/src/mqtt_client_connector.dart';
import 'package:mqtt/src/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('MqttServiceImpl');

class MqttServiceImpl implements MqttService {
  MqttServiceImpl({
    required String mqttUrl,
    required MqttClientConnector mqttClientConnector,
    required this.deviceId,
    required this.prefix,
  }) : _mqttUrl = mqttUrl,
       _mqttClientConnector = mqttClientConnector {
    _init();
  }

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
  }

  @override
  void disconnect() {
    _log.info('Disconnecting from MQTT broker');
    _client.disconnect();
  }

  @override
  Future<bool> connect(String company, String train) async {
    if (_client.connectionStatus?.state != MqttConnectionState.disconnected) {
      _client.disconnect();
    }
    if (await _mqttClientConnector.connect(_client, company, train)) {
      _client.subscribe('${prefix}90940/2/event/$company/$train', MqttQos.exactlyOnce);
      _client.subscribe('${prefix}90940/2/event/$company/$train/$deviceId', MqttQos.exactlyOnce);
      _client.subscribe('${prefix}90940/2/G2B/$company/$train/$deviceId', MqttQos.exactlyOnce);
      _log.info("Subscribed to topic with prefix='$prefix'...");
      _startUpdateListener();
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
}

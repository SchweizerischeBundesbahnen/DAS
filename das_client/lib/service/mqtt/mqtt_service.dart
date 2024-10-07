import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:das_client/service/mqtt/mqtt_client_connector.dart';
import 'package:das_client/util/device_id_info.dart';
import 'package:fimber/fimber.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:rxdart/rxdart.dart';

class MqttService {
  final String _mqttUrl;
  final MqttClientConnector _mqttClientConnector;

  late MqttServerClient _client;
  late String _deviceId;

  StreamSubscription? _updateSubscription;

  final _messageSubject = BehaviorSubject<String>();

  Stream<String> get messageStream => _messageSubject.stream;

  MqttService({required String mqttUrl, required MqttClientConnector mqttClientConnector})
      : _mqttUrl = mqttUrl,
        _mqttClientConnector = mqttClientConnector {
    _init();
  }

  void _init() async {
    _deviceId = await DeviceIdInfo.getDeviceId();
    _client = MqttServerClient.withPort(_mqttUrl, _deviceId, 8443);
    _client.useWebSocket = true;
  }

  void disconnect() {
    Fimber.i("Disconnecting from MQTT broker");
    _client.disconnect();
  }

  Future<bool> connect(String company, String train) async {
    if (_client.connectionStatus?.state != MqttConnectionState.disconnected) {
      _client.disconnect();
    }
    if (await _mqttClientConnector.connect(_client, company, train)) {
      _client.subscribe("90940/2/G2B/$company/$train", MqttQos.exactlyOnce);
      _client.subscribe("90940/2/G2B/$company/$train/$_deviceId", MqttQos.exactlyOnce);
      Fimber.i("Subscribed to topic...");
      _startUpdateListener();
      return true;
    }

    return false;
  }

  bool publishMessage(String company, String train, String message) {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      final topic = "90940/2/B2G/$company/$train/$_deviceId";

      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);

      Fimber.v("Published MQTT message: topic=$topic message=$message");
      return true;
    } else {
      Fimber.w("Failed to publish MQTT message because it is not connected");
      return false;
    }
  }

  void _startUpdateListener() {
    _updateSubscription?.cancel();
    _updateSubscription = _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>>? messageList) {
      if (messageList != null) {
        for (final message in messageList) {
          Fimber.v(
              "Received mqtt message with type=${message.runtimeType.toString()} payload=${message.payload.toString()}");

          if (message.payload is MqttPublishMessage) {
            final recMess = message.payload as MqttPublishMessage;
            final decodedMessage = utf8.decode(recMess.payload.message);
            Fimber.v("Decoded mqtt message: $decodedMessage");
            _messageSubject.add(decodedMessage);
          } else {
            Fimber.w("Type ${message.payload.runtimeType.toString()} parsing not implemented");
          }
        }
      } else {
        Fimber.w("received mqtt update with messageList=null");
      }
    });
  }
}

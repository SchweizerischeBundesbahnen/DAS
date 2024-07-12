import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:das_client/auth/authenticator.dart';
import 'package:das_client/service/backend_service.dart';
import 'package:das_client/util/device_id_info.dart';
import 'package:fimber/fimber.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:rxdart/rxdart.dart';

class MqttService {
  final String _mqttUrl;
  final BackendService _backendService;
  final Authenticator _authenticator;

  late MqttServerClient _client;
  late String _deviceId;

  StreamSubscription? _updateSubscription;
  Subscription? _trainSubscription;

  final _messageSubject = BehaviorSubject<String>();

  Stream<String> get messageStream => _messageSubject.stream;

  MqttService({required String mqttUrl, required BackendService backendService, required Authenticator authenticator})
      : _mqttUrl = mqttUrl,
        _backendService = backendService,
        _authenticator = authenticator {
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

    Fimber.i("Establishing connection to MQTT broker with company=$company train=$train");
    var sferaAuthToken = await _backendService.retrieveSferaAuthToken(company, train, "active");

    Fimber.i("Received sfera token=${sferaAuthToken?.substring(0, 20)}");
    var token = await _authenticator.token();
    var jsonWebToken = token.accessToken.toJwt();
    var userId = jsonWebToken.payload["preferred_username"];
    Fimber.i("Using userId=$userId");

    if (sferaAuthToken != null && userId != null) {
      try {
        var mqttClientConnectionStatus = await _client.connect(userId, "OAUTH~azureAd~$sferaAuthToken");
        Fimber.i("mqttClientConnectionStatus=$mqttClientConnectionStatus");

        if (mqttClientConnectionStatus?.state == MqttConnectionState.connected) {
          _trainSubscription = _client.subscribe("90940/2/G2B/$company/$train/$_deviceId", MqttQos.exactlyOnce);
          Fimber.i("Established connection to MQTT broker!");
          _startUpdateListener();
          return true;
        }
      } catch (e) {
        Fimber.e("Exception during connect", ex: e);
      }
    }
    Fimber.w("Failed to connect to MQTT broker");
    return false;
  }

  bool publishMessage(String company, String train, String message) {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      final topic = "90940/2/B2G/$company/$train/$_deviceId";

      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);

      Fimber.v(
          "Published MQTT message: topic=$topic message=$message");
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

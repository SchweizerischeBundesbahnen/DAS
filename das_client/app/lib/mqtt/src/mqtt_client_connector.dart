import 'package:mqtt_client/mqtt_client.dart';

abstract class MqttClientConnector {
  const MqttClientConnector._();

  Future<bool> connect(MqttClient client, String company, String train);
}

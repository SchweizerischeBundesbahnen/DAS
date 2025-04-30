import 'package:app/mqtt/mqtt_component.dart';
import 'package:fimber/fimber.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttClientUserConnector implements MqttClientConnector {
  static const mqttUsername = 'MQTT_USERNAME';
  static const mqttPassword = 'MQTT_PASSWORD';

  @override
  Future<bool> connect(MqttClient client, String company, String train) async {
    Fimber.i('Connecting to mqtt using static login and password');

    if (!const bool.hasEnvironment(mqttUsername) || !const bool.hasEnvironment(mqttPassword)) {
      Fimber.e('$mqttUsername or $mqttPassword not defined');
      return false;
    }

    try {
      final mqttClientConnectionStatus =
          await client.connect(const String.fromEnvironment(mqttUsername), const String.fromEnvironment(mqttPassword));
      Fimber.i('mqttClientConnectionStatus=$mqttClientConnectionStatus');

      if (mqttClientConnectionStatus?.state == MqttConnectionState.connected) {
        Fimber.i('Successfully connected to MQTT broker');
        return true;
      }
    } catch (e) {
      Fimber.e('Exception during connect', ex: e);
    }

    Fimber.w('Failed to connect to MQTT broker');
    return false;
  }
}

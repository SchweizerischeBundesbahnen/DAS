import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';

final _log = Logger('MqttClientUserConnector');

class MqttClientUserConnector implements MqttClientConnector {
  static const mqttUsername = 'MQTT_USERNAME';
  static const mqttPassword = 'MQTT_PASSWORD';

  bool forceFailToConnect = false;

  @override
  Future<bool> connect(MqttClient client, String company, String train) async {
    _log.info('Connecting to mqtt using static login and password');

    if (forceFailToConnect) {
      _log.warning('Forced failure to connect to MQTT broker');
      return false;
    }

    if (!const bool.hasEnvironment(mqttUsername) || !const bool.hasEnvironment(mqttPassword)) {
      _log.severe('$mqttUsername or $mqttPassword not defined');
      return false;
    }

    try {
      final mqttClientConnectionStatus = await client.connect(
        const String.fromEnvironment(mqttUsername),
        const String.fromEnvironment(mqttPassword),
      );
      _log.info('mqttClientConnectionStatus=$mqttClientConnectionStatus');

      if (mqttClientConnectionStatus?.state == MqttConnectionState.connected) {
        _log.info('Successfully connected to MQTT broker');
        return true;
      }
    } catch (e) {
      _log.severe('Exception during connect', e);
    }

    _log.warning('Failed to connect to MQTT broker');
    return false;
  }
}

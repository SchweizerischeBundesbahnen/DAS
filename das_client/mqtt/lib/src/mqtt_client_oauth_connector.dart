import 'package:fimber/fimber.dart';
import 'package:mqtt/src/mqtt_client_connector.dart';
import 'package:mqtt/src/provider/mqtt_auth_provider.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttClientOauthConnector implements MqttClientConnector {
  MqttClientOauthConnector({required MqttAuthProvider mqttAuthProvider}) : _mqttAuthProvider = mqttAuthProvider;

  final MqttAuthProvider _mqttAuthProvider;

  @override
  Future<bool> connect(MqttClient client, String company, String train) async {
    Fimber.i('Connecting to mqtt using oauth token');

    final userId = await _mqttAuthProvider.userId();
    Fimber.i('Using userId=$userId');

    try {
      final accessToken = await _mqttAuthProvider.token();
      final mqttClientConnectionStatus = await client.connect(userId, 'OAUTH~azureAd~$accessToken');
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

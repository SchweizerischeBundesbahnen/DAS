import 'package:das_client/auth/authentication_component.dart';
import 'package:das_client/mqtt/src/mqtt_client_connector.dart';
import 'package:fimber/fimber.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttClientOauthConnector implements MqttClientConnector {
  final Authenticator _authenticator;

  MqttClientOauthConnector({required Authenticator authenticator}) : _authenticator = authenticator;

  @override
  Future<bool> connect(MqttClient client, String company, String train) async {
    Fimber.i('Connecting to mqtt using oauth token');

    final token = await _authenticator.token();
    final jsonWebToken = token.accessToken.toJwt();
    final userId = jsonWebToken.payload['preferred_username'];
    Fimber.i('Using userId=$userId');

    if (userId != null) {
      try {
        final mqttClientConnectionStatus = await client.connect(userId, 'OAUTH~azureAd~${token.accessToken}');
        Fimber.i('mqttClientConnectionStatus=$mqttClientConnectionStatus');

        if (mqttClientConnectionStatus?.state == MqttConnectionState.connected) {
          Fimber.i('Successfully connected to MQTT broker');
          return true;
        }
      } catch (e) {
        Fimber.e('Exception during connect', ex: e);
      }
    }

    Fimber.w('Failed to connect to MQTT broker');
    return false;
  }
}

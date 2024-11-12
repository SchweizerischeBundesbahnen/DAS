import 'package:das_client/mqtt/src/mqtt_client_connector.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:fimber/fimber.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttClientTMSOauthConnector implements MqttClientConnector {
  final SferaAuthService _sferaAuthService;

  MqttClientTMSOauthConnector({required SferaAuthService sferaAuthService}) : _sferaAuthService = sferaAuthService;

  @override
  Future<bool> connect(MqttClient client, String company, String train) async {
    Fimber.i('Connecting to TMS mqtt using oauth token');

    final sferaAuthToken = await _sferaAuthService.retrieveSferaAuthToken(company, train, 'active');
    Fimber.i('Received TMS sfera token=${sferaAuthToken?.substring(0, 20)}');

    if (sferaAuthToken != null) {
      try {
        final mqttClientConnectionStatus = await client.connect('JWT', 'OPENID~AzureAD_IMTS~~$sferaAuthToken');
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

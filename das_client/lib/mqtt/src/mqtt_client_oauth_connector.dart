import 'package:das_client/auth/src/authenticator.dart';
import 'package:das_client/mqtt/src/mqtt_client_connector.dart';
import 'package:das_client/sfera/src/service/sfera_auth_service.dart';
import 'package:fimber/fimber.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttClientOauthConnector implements MqttClientConnector {
  final SferaAuthService _sferaAuthService;
  final Authenticator _authenticator;

  MqttClientOauthConnector({required SferaAuthService sferaAuthService, required Authenticator authenticator})
      : _sferaAuthService = sferaAuthService,
        _authenticator = authenticator;

  @override
  Future<bool> connect(MqttClient client, String company, String train) async {
    Fimber.i('Connecting to mqtt using oauth token');

    var sferaAuthToken = await _sferaAuthService.retrieveSferaAuthToken(company, train, 'active');

    Fimber.i('Received sfera token=${sferaAuthToken?.substring(0, 20)}');
    var token = await _authenticator.token();
    var jsonWebToken = token.accessToken.toJwt();
    var userId = jsonWebToken.payload['preferred_username'];
    Fimber.i('Using userId=$userId');

    if (sferaAuthToken != null && userId != null) {
      try {
        var mqttClientConnectionStatus = await client.connect(userId, 'OAUTH~azureAd~$sferaAuthToken');
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

import 'package:das_client/auth/authenticator.dart';
import 'package:das_client/service/backend_service.dart';
import 'package:das_client/service/mqtt/mqtt_client_connector.dart';
import 'package:fimber/fimber.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttClientOauthConnector implements MqttClientConnector {
  final BackendService _backendService;
  final Authenticator _authenticator;

  MqttClientOauthConnector({required BackendService backendService, required Authenticator authenticator})
      : _backendService = backendService,
        _authenticator = authenticator;

  @override
  Future<bool> connect(MqttClient client, String company, String train) async {
    Fimber.i("Connecting to mqtt using oauth token");

    var sferaAuthToken = await _backendService.retrieveSferaAuthToken(company, train, "active");

    Fimber.i("Received sfera token=${sferaAuthToken?.substring(0, 20)}");
    var token = await _authenticator.token();
    var jsonWebToken = token.accessToken.toJwt();
    var userId = jsonWebToken.payload["preferred_username"];
    Fimber.i("Using userId=$userId");

    if (sferaAuthToken != null && userId != null) {
      try {
        var mqttClientConnectionStatus = await client.connect(userId, "OAUTH~azureAd~$sferaAuthToken");
        Fimber.i("mqttClientConnectionStatus=$mqttClientConnectionStatus");

        if (mqttClientConnectionStatus?.state == MqttConnectionState.connected) {
          Fimber.i("Successfully connected to MQTT broker");
          return true;
        }
      } catch (e) {
        Fimber.e("Exception during connect", ex: e);
      }
    }

    Fimber.w("Failed to connect to MQTT broker");
    return false;
  }
}

import 'package:logging/logging.dart';
import 'package:mqtt/src/mqtt_client_connector.dart';
import 'package:mqtt/src/provider/mqtt_auth_provider.dart';
import 'package:mqtt_client/mqtt_client.dart';

final _log = Logger('MqttClientOauthConnector');

class MqttClientOauthConnector implements MqttClientConnector {
  MqttClientOauthConnector({required MqttAuthProvider mqttAuthProvider}) : _mqttAuthProvider = mqttAuthProvider;

  final MqttAuthProvider _mqttAuthProvider;

  @override
  Future<bool> connect(MqttClient client, String company, String train) async {
    _log.info('Connecting to mqtt using oauth token');

    final userId = await _mqttAuthProvider.userId();
    _log.info('Using userId=$userId');

    try {
      final accessToken = await _mqttAuthProvider.token();
      final mqttClientConnectionStatus = await client.connect(
        userId,
        'OAUTH~${_mqttAuthProvider.oauthProfile}~$accessToken',
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

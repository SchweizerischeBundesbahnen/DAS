import 'package:logging/logging.dart';
import 'package:mqtt/src/mqtt_client_connector.dart';
import 'package:mqtt/src/provider/mqtt_auth_provider.dart';
import 'package:mqtt_client/mqtt_client.dart';

final _log = Logger('MqttClientTMSOauthConnector');

class MqttClientTMSOpenIdConnector implements MqttClientConnector {
  MqttClientTMSOpenIdConnector({
    required MqttAuthProvider mqttAuthProvider,
    required Map<String, String> openIdProfileMap,
  }) : _mqttAuthProvider = mqttAuthProvider,
       _openIdProfileMap = openIdProfileMap;

  final MqttAuthProvider _mqttAuthProvider;
  final Map<String, String> _openIdProfileMap;

  @override
  Future<bool> connect(MqttClient client, String company, String train) async {
    final tid = await _mqttAuthProvider.tid();
    final openIdProfile = _openIdProfileMap[tid];

    _log.info('Connecting to TMS mqtt using openid token with openIdProfile=$openIdProfile');

    final sferaAuthToken = await _mqttAuthProvider.token();

    try {
      final mqttClientConnectionStatus = await client.connect('JWT', 'OPENID~$openIdProfile~~$sferaAuthToken');
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

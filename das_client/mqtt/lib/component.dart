import 'package:mqtt/src/mqtt_client_connector.dart';
import 'package:mqtt/src/mqtt_client_oauth_connector.dart';
import 'package:mqtt/src/mqtt_client_tms_open_id_connector.dart';
import 'package:mqtt/src/mqtt_service.dart';
import 'package:mqtt/src/mqtt_service_impl.dart';
import 'package:mqtt/src/provider/mqtt_auth_provider.dart';

export 'package:mqtt/src/mqtt_client_connector.dart';
export 'package:mqtt/src/mqtt_service.dart';
export 'package:mqtt/src/provider/mqtt_auth_provider.dart';
export 'package:mqtt_client/mqtt_client.dart';

class MqttComponent {
  const MqttComponent._();

  static MqttService createMqttService({
    required String mqttUrl,
    required MqttClientConnector mqttClientConnector,
    required String deviceId,
    required String prefix,
    required String sferaVersion,
  }) {
    return MqttServiceImpl(
      mqttUrl: mqttUrl,
      mqttClientConnector: mqttClientConnector,
      prefix: prefix,
      deviceId: deviceId,
      sferaVersion: sferaVersion,
    );
  }

  static MqttClientConnector createOAuthClientConnector({required MqttAuthProvider authProvider}) =>
      MqttClientOauthConnector(mqttAuthProvider: authProvider);

  static MqttClientConnector createOpenIdClientConnector({
    required MqttAuthProvider authProvider,
    required Map<String, String> openIdProfileMap,
  }) => MqttClientTMSOpenIdConnector(mqttAuthProvider: authProvider, openIdProfileMap: openIdProfileMap);
}

import 'package:mqtt/src/mqtt_client_connector.dart';
import 'package:mqtt/src/mqtt_client_oauth_connector.dart';
import 'package:mqtt/src/mqtt_client_tms_oauth_connector.dart';
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
  }) {
    return MqttServiceImpl(
      mqttUrl: mqttUrl,
      mqttClientConnector: mqttClientConnector,
      prefix: prefix,
      deviceId: deviceId,
    );
  }

  static MqttClientConnector createOAuthClientConnector({required MqttAuthProvider authProvider}) =>
      MqttClientOauthConnector(mqttAuthProvider: authProvider);

  static MqttClientConnector createOpenIdClientConnector({required MqttAuthProvider authProvider}) =>
      MqttClientTMSOauthConnector(mqttAuthProvider: authProvider);
}

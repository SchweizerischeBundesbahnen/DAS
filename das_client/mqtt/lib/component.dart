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

  static MqttClientConnector createMqttClientConnector({
    required MqttAuthProvider authProvider,
    required String oauthProfile,
    bool useTms = false,
  }) {
    if (useTms) {
      return MqttClientTMSOauthConnector(mqttAuthProvider: authProvider);
    }
    return MqttClientOauthConnector(mqttAuthProvider: authProvider, oauthProfile: oauthProfile);
  }

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
}

import 'package:app/sfera/sfera_component.dart';
import 'package:auth/component.dart';
import 'package:mqtt/src/mqtt_client_connector.dart';
import 'package:mqtt/src/mqtt_client_oauth_connector.dart';
import 'package:mqtt/src/mqtt_client_tms_oauth_connector.dart';
import 'package:mqtt/src/mqtt_service.dart';
import 'package:mqtt/src/mqtt_service_impl.dart';

export 'package:mqtt/src/mqtt_client_connector.dart';
export 'package:mqtt/src/mqtt_service.dart';

// TODO: Remove dependency to sfera component
class MqttComponent {
  const MqttComponent._();

  static MqttClientConnector createMqttClientConnector({
    required SferaAuthService sferaAuthService,
    required Authenticator authenticator,
    bool useTms = false,
  }) {
    if (useTms) {
      return MqttClientTMSOauthConnector(sferaAuthService: sferaAuthService);
    }
    return MqttClientOauthConnector(authenticator: authenticator);
  }

  static MqttService createMqttService({
    required String mqttUrl,
    required MqttClientConnector mqttClientConnector,
    required String prefix,
  }) {
    return MqttServiceImpl(mqttUrl: mqttUrl, mqttClientConnector: mqttClientConnector, prefix: prefix);
  }
}

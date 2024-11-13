import 'package:das_client/auth/authentication_component.dart';
import 'package:das_client/mqtt/src/mqtt_client_connector.dart';
import 'package:das_client/mqtt/src/mqtt_client_oauth_connector.dart';
import 'package:das_client/mqtt/src/mqtt_client_tms_oauth_connector.dart';
import 'package:das_client/mqtt/src/mqtt_service.dart';
import 'package:das_client/mqtt/src/mqtt_service_impl.dart';
import 'package:das_client/sfera/sfera_component.dart';

export 'package:das_client/mqtt/src/mqtt_client_connector.dart';
export 'package:das_client/mqtt/src/mqtt_service.dart';

class MqttComponent {
  const MqttComponent._();

  static MqttClientConnector createMqttClientConnector(
      {required SferaAuthService sfereAuthService, required Authenticator authenticator, bool useTms = false}) {
    if (useTms) {
      return MqttClientTMSOauthConnector(sferaAuthService: sfereAuthService);
    } else {
      return MqttClientOauthConnector(authenticator: authenticator);
    }
  }

  static MqttService createMqttService(
      {required String mqttUrl, required MqttClientConnector mqttClientConnector, required String prefix}) {
    return MqttServiceImpl(mqttUrl: mqttUrl, mqttClientConnector: mqttClientConnector, prefix: prefix);
  }
}

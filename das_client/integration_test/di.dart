import 'package:battery_plus/battery_plus.dart';
import 'package:das_client/auth/authentication_component.dart';
import 'package:das_client/brightness/brightness_manager.dart';
import 'package:das_client/di.dart';
import 'package:das_client/flavor.dart';
import 'package:das_client/mqtt/mqtt_component.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';

import 'auth/integrationtest_authenticator.dart';
import 'auth/mqtt_client_user_connector.dart';
import 'mocks/battery_mock.dart';
import 'mocks/brightness_mock.dart';

class IntegrationTestDI {
  const IntegrationTestDI._();

  static Future<void> init(Flavor flavor) async {
    Fimber.i('Initialize integration test dependency injection');
    await GetIt.I.reset();

    GetIt.I.registerFlavor(flavor);
    GetIt.I.registerTokenSpecProvider();
    GetIt.I.registerOidcClient();
    _registerIntegrationTestAuthenticator();
    GetIt.I.registerSferaComponents();
    GetIt.I.registerMqttComponent();
    _registerBattery();
    _registerBrightnessManager();

    GetIt.I.registerBlocs();
    GetIt.I.registerAudioPlayer();

    GetIt.I.unregister<MqttClientConnector>();
    _registerMqttClientConnector();

    await GetIt.I.allReady();
  }

  static void _registerIntegrationTestAuthenticator() {
    GetIt.I.registerSingletonAsync<Authenticator>(() async => IntegrationTestAuthenticator());
  }

  static void _registerMqttClientConnector() {
    GetIt.I.registerSingletonAsync<MqttClientConnector>(() async => MqttClientUserConnector());
  }

  static void _registerBattery() {
    GetIt.I.registerSingletonAsync<Battery>(() async => BatteryMock());
  }

  static void _registerBrightnessManager() {
    GetIt.I.registerSingleton<BrightnessManager>(MockBrightnessManager());
  }
}

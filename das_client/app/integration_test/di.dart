import 'package:app/time_controller/time_controller.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:auth/component.dart';
import 'package:app/brightness/brightness_manager.dart';
import 'package:app/di.dart';
import 'package:app/flavor.dart';
import 'package:mqtt/component.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:screen_brightness/screen_brightness.dart';

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
    _registerScreenBrightness();
    _registerBrightnessManager();
    _registerTimeController();
    _registerIntegrationTestAuthenticator();
    GetIt.I.registerAuthProvider();
    GetIt.I.registerSferaAuthProvider();
    GetIt.I.registerMqttAuthProvider();
    _registerMqttClientConnector();
    GetIt.I.registerMqttService();
    GetIt.I.registerSferaAuthService();
    GetIt.I.registerSferaLocalRepo();
    GetIt.I.registerSferaRemoteRepo();
    _registerBattery();
    GetIt.I.registerBlocs();
    GetIt.I.registerAudioPlayer();

    await GetIt.I.allReady();
  }

  static void _registerTimeController() {
    GetIt.I.registerLazySingleton<TimeController>(() => TimeController());
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

  static void _registerScreenBrightness() {
    GetIt.I.registerLazySingleton<ScreenBrightness>(() => ScreenBrightness());
  }

  static void _registerBrightnessManager() {
    GetIt.I.registerLazySingleton<BrightnessManager>(
      () => MockBrightnessManager(),
    );
  }
}

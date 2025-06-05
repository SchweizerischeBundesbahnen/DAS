import 'package:app/brightness/brightness_manager.dart';
import 'package:app/di.dart';
import 'package:app/flavor.dart';
import 'package:auth/component.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:mqtt/component.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:warnapp/component.dart';

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
    GetIt.I.registerAudioPlayer();
    _registerMockMotionDataService();
    GetIt.I.registerWarnapp();

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

  static void _registerScreenBrightness() {
    GetIt.I.registerLazySingleton<ScreenBrightness>(() => ScreenBrightness());
  }

  static void _registerMockMotionDataService() {
    GetIt.I.registerSingleton<MotionDataService>(
      WarnappComponent.createMockMotionDataService(samplingPeriod: Duration(milliseconds: 2)),
    );
  }

  static void _registerBrightnessManager() {
    GetIt.I.registerLazySingleton<BrightnessManager>(
      () => MockBrightnessManager(),
    );
  }
}

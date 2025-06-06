import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:mqtt/component.dart';

class SferaMockScope {
  SferaMockScope._();

  static const String _scopeName = 'SferaMockScope';
  static final _getIt = GetIt.I;

  static Future<void> push() async {
    Fimber.d('Pushing scope $_scopeName');
    _getIt.pushNewScope(scopeName: _scopeName);
    final sferaFlavor = DI.get<Flavor>().withSferaMockValues();

    _getIt.registerFlavor(sferaFlavor);
    _getIt.registerAzureAuthenticator();

    _getIt.registerOAuthMqttClientConnector();
  }

  Future<void> pop() async {
    Fimber.d('Popping scope $_scopeName');
    await _getIt.popScopesTill(_scopeName);
  }
}

extension SferaMockExtension on GetIt {
  void registerOAuthMqttClientConnector() {
    factoryFunc() {
      Fimber.d('Register mqtt client connector');
      return MqttComponent.createOAuthClientConnector(authProvider: DI.get());
    }

    registerLazySingleton<MqttClientConnector>(factoryFunc);
  }
}

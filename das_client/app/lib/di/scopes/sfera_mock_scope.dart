import 'package:app/di/di.dart';
import 'package:app/di/scopes/di_scope.dart';
import 'package:app/flavor.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:mqtt/component.dart';

class SferaMockScope extends DIScope {
  @override
  String get scopeName => 'SferaMockScope';

  @override
  Future<void> push() async {
    Fimber.d('Pushing scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);
    final sferaFlavor = DI.get<Flavor>().withSferaMockValues();

    getIt.registerFlavor(sferaFlavor);
    getIt.registerAzureAuthenticator();

    getIt.registerOAuthMqttClientConnector();
  }
}

extension SferaMockScopeExtension on GetIt {
  void registerOAuthMqttClientConnector() {
    factoryFunc() {
      Fimber.d('Register mqtt client connector');
      return MqttComponent.createOAuthClientConnector(authProvider: DI.get());
    }

    registerLazySingleton<MqttClientConnector>(factoryFunc);
  }
}

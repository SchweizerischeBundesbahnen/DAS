part of 'di_scope.dart';

class SferaMockScope extends DIScope {
  static const String scopeName = 'SferaMockScope';

  @override
  String get _scopeName => scopeName;

  @override
  Future<void> push() async {
    Fimber.d('Pushing scope $_scopeName');
    _getIt.pushNewScope(scopeName: _scopeName);
    final sferaFlavor = DI.get<Flavor>().withSferaMockValues();

    _getIt.registerFlavor(sferaFlavor);
    _getIt.registerAzureAuthenticator();

    _getIt.registerOAuthMqttClientConnector();
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

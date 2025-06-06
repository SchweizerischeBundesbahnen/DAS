part of 'di_scope.dart';

class TmsScope extends DIScope {
  static get scopeName => 'TmsScope';

  @override
  String get _scopeName => scopeName;

  @override
  Future<void> push() async {
    Fimber.d('Pushing scope $_scopeName');
    _getIt.pushNewScope(scopeName: _scopeName);
    final tmsFlavor = DI.get<Flavor>().withTmsValues();

    _getIt.registerFlavor(tmsFlavor);
    _getIt.registerAzureAuthenticator();

    _getIt.registerOpenIdMqttClientConnector();
  }
}

extension TmsScopeExtension on GetIt {
  void registerOpenIdMqttClientConnector() {
    factoryFunc() {
      Fimber.d('Register mqtt client connector');
      return MqttComponent.createOpenIdClientConnector(authProvider: DI.get());
    }

    registerLazySingleton<MqttClientConnector>(factoryFunc);
  }
}

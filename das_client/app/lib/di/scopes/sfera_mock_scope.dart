import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';

final _log = Logger('SferaMockScope');

class SferaMockScope extends DIScope {
  @override
  String get scopeName => 'SferaMockScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing scope $scopeName');
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
      _log.fine('Register mqtt client connector');
      return MqttComponent.createOAuthClientConnector(authProvider: DI.get());
    }

    registerLazySingleton<MqttClientConnector>(factoryFunc);
  }
}

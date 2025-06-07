import 'package:app/di/di.dart';
import 'package:app/di/scopes/di_scope.dart';
import 'package:app/flavor.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:mqtt/component.dart';

class TmsScope extends DIScope {
  @override
  String get scopeName => 'TmsScope';

  @override
  Future<void> push() async {
    Fimber.d('Pushing scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);
    final tmsFlavor = DI.get<Flavor>().withTmsValues();

    getIt.registerFlavor(tmsFlavor);
    getIt.registerAzureAuthenticator();

    getIt.registerOpenIdMqttClientConnector();
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

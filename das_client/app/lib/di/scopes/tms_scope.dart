import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';

final _log = Logger('TmsScope');

class TmsScope extends DIScope {
  @override
  String get scopeName => 'TmsScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing scope $scopeName');
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
      _log.fine('Register mqtt client connector');
      return MqttComponent.createOpenIdClientConnector(authProvider: DI.get());
    }

    registerLazySingleton<MqttClientConnector>(factoryFunc);
  }
}

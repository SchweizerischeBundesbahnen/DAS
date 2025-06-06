import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:mqtt/component.dart';

class TmsScope {
  TmsScope._();

  static const String _scopeName = 'TmsScope';
  static final _getIt = GetIt.I;

  static Future<void> push() async {
    Fimber.d('Pushing scope $_scopeName');
    _getIt.pushNewScope(scopeName: _scopeName);
    final tmsFlavor = DI.get<Flavor>().withTmsValues();

    _getIt.registerFlavor(tmsFlavor);
    _getIt.registerAzureAuthenticator();

    _getIt.registerOpenIdMqttClientConnector();
  }

  Future<void> pop() async {
    Fimber.d('Popping scope $_scopeName');
    await _getIt.popScopesTill(_scopeName);
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

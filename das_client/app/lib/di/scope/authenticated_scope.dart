import 'package:app/di/di.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:mqtt/component.dart';

class AuthenticatedScope {
  AuthenticatedScope._();

  static const String _scopeName = 'AuthenticatedScope';
  static final _getIt = GetIt.I;

  static Future<void> push() async {
    Fimber.d('Pushing scope $_scopeName');
    _getIt.pushNewScope(scopeName: _scopeName);

    _getIt.registerAuthProvider();
    _getIt.registerSferaAuthProvider();
    _getIt.registerSferaAuthService();
    _getIt.registerMqttAuthProvider();
    _getIt.registerMqttService();
    _getIt.registerDasLogTree();
    _getIt.registerSferaLocalRepo();
    _getIt.registerSferaRemoteRepo();
    // TODO: register TrainJourneySelectionViewModel

    return _getIt.allReady();
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

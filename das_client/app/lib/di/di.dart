import 'package:app/di/scope_handler.dart';
import 'package:app/di/scope_handler_impl.dart';
import 'package:app/di/scopes/scopes.dart';
import 'package:app/flavor.dart';
import 'package:auth/component.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

export 'package:app/di/scopes/scopes.dart';

final _log = Logger('DI');

class DI {
  const DI._();

  static Future<void> init(Flavor flavor) {
    _log.fine('Initialize dependency injection');
    GetIt.I.registerFlavor(flavor);
    GetIt.I.registerScopes();
    GetIt.I.registerScopeHandler();
    return GetIt.I.allReady();
  }

  static Future<void> resetToUnauthenticatedScope({required bool useTms}) async {
    _log.info('LoginScope with useTms=$useTms');

    final scopeHandler = DI.get<ScopeHandler>();
    if (scopeHandler.isInStack<AuthenticatedScope>()) await scopeHandler.pop<AuthenticatedScope>();

    if (useTms) {
      if (scopeHandler.isTop<SferaMockScope>()) await scopeHandler.pop<SferaMockScope>();
      if (!scopeHandler.isTop<TmsScope>()) await scopeHandler.push<TmsScope>();
    } else {
      if (scopeHandler.isTop<TmsScope>()) await scopeHandler.pop<TmsScope>();
      if (!scopeHandler.isTop<SferaMockScope>()) await scopeHandler.push<SferaMockScope>();
    }
  }

  static T? getOrNull<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) {
    try {
      return get<T>(
        instanceName: instanceName,
        param1: param1,
        param2: param2,
      );
    } catch (e) {
      return null;
    }
  }

  static T get<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) {
    return GetIt.I.get(
      instanceName: instanceName,
      param1: param1,
      param2: param2,
    );
  }
}

extension DiExtension on GetIt {
  void registerScopeHandler() {
    _log.fine('Register scope handler');
    registerSingleton<ScopeHandler>(ScopeHandlerImpl());
  }

  void registerFlavor(Flavor flavor) {
    _log.fine('Register flavor');
    registerSingleton<Flavor>(flavor);
    registerSingleton<String>(flavor.backendUrl, instanceName: 'backendUrl');
  }

  void registerAzureAuthenticator() {
    factoryFunc() {
      _log.fine('Register azure authenticator');
      final flavor = DI.get<Flavor>();
      final authenticatorConfig = flavor.authenticatorConfig;
      return AuthenticationComponent.createAzureAuthenticator(config: authenticatorConfig);
    }

    registerSingleton<Authenticator>(factoryFunc());
  }

  void registerScopes() {
    _log.fine('Registering scopes');
    registerSingleton<DASBaseScope>(DASBaseScope());
    registerSingleton<SferaMockScope>(SferaMockScope());
    registerSingleton<TmsScope>(TmsScope());
    registerSingleton<AuthenticatedScope>(AuthenticatedScope());
  }
}

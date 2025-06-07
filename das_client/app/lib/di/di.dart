import 'package:app/di/scope_handler.dart';
import 'package:app/di/scope_handler_impl.dart';
import 'package:app/di/scopes/scopes.dart';
import 'package:app/flavor.dart';
import 'package:auth/component.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';

export 'package:app/di/scopes/scopes.dart';

class DI {
  const DI._();

  static Future<void> init(Flavor flavor) {
    Fimber.d('Initialize dependency injection');
    GetIt.I.registerFlavor(flavor);
    GetIt.I.registerScopes();
    GetIt.I.registerScopeHandler();
    return GetIt.I.allReady();
  }

  /// The login scope is either the TMS scope or the Sfera mock scope.
  static Future<void> loginScope({required bool useTms}) async {
    Fimber.i('LoginScope with useTms=$useTms');

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
    Fimber.d('Register scope handler');
    registerSingleton<ScopeHandler>(ScopeHandlerImpl());
  }

  void registerFlavor(Flavor flavor) {
    Fimber.d('Register flavor');
    registerSingleton<Flavor>(flavor);
  }

  void registerAzureAuthenticator() {
    factoryFunc() {
      Fimber.d('Register azure authenticator');
      final flavor = DI.get<Flavor>();
      final authenticatorConfig = flavor.authenticatorConfig;
      return AuthenticationComponent.createAzureAuthenticator(config: authenticatorConfig);
    }

    registerSingleton<Authenticator>(factoryFunc());
  }

  void registerScopes() {
    Fimber.d('Registering scopes');
    registerSingleton<DASBaseScope>(DASBaseScope());
    registerSingleton<SferaMockScope>(SferaMockScope());
    registerSingleton<TmsScope>(TmsScope());
    registerSingleton<AuthenticatedScope>(AuthenticatedScope());
  }
}

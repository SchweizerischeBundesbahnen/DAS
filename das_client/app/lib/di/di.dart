import 'package:app/di/scope_handler.dart';
import 'package:app/di/scope_handler_impl.dart';
import 'package:app/di/scopes/di_scope.dart';
import 'package:app/flavor.dart';
import 'package:auth/component.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';

export 'package:app/di/scopes/di_scope.dart' show AuthenticatedScopeExtension;
export 'package:app/di/scopes/di_scope.dart' show BaseScopeExtension;
export 'package:app/di/scopes/di_scope.dart' show SferaMockScopeExtension;
export 'package:app/di/scopes/di_scope.dart' show TmsScopeExtension;

class DI {
  const DI._();

  static Future<void> init(Flavor flavor) {
    Fimber.i('Initialize dependency injection');
    return GetIt.I.init(flavor);
  }

  static Future<void> reinitialize({required bool useTms}) async {
    Fimber.i('Reinitialize dependency injection with useTms=$useTms');
    final LogTree? logTree = getOrNull<LogTree>();
    if (logTree != null) {
      Fimber.d('Unplanting existing log tree');
      Fimber.unplantTree(logTree);
    }

    final scopeHandler = DI.get<ScopeHandler>();
    await scopeHandler.popAbove<DASBaseScope>();
    if (useTms) {
      Fimber.d('Using TMS scope');
      await scopeHandler.push<TmsScope>();
    } else {
      Fimber.d('Using Sfera mock scope');
      await scopeHandler.push<SferaMockScope>();
    }

    await GetIt.I.allReady();
  }

  static T? getOrNull<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) {
    try {
      return GetIt.I.get<T>(
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

// Internal

extension GetItX on GetIt {
  Future<void> init(Flavor flavor) async {
    // Register flavor and scope handler before any scopes.
    registerFlavor(flavor);
    registerScopeHandler();

    final scopeHandler = get<ScopeHandler>();
    await scopeHandler.push<DASBaseScope>();
    await scopeHandler.push<SferaMockScope>();
    await allReady();
  }

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

    registerSingleton<Authenticator>(factoryFunc(), dispose: (authenticator) => authenticator.dispose());
  }
}

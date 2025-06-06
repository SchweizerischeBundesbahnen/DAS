import 'package:app/di/scope/base_scope.dart';
import 'package:app/di/scope/sfera_mock_scope.dart';
import 'package:app/flavor.dart';
import 'package:auth/component.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';

export 'package:app/di/scope/authenticated_scope.dart' show AuthenticatedScopeExtension;
export 'package:app/di/scope/base_scope.dart' show BaseScopeExtension;
export 'package:app/di/scope/sfera_mock_scope.dart' show SferaMockScopeExtension;
export 'package:app/di/scope/tms_scope.dart' show TmsScopeExtension;

class DI {
  const DI._();

  static Future<void> init(Flavor flavor) {
    Fimber.i('Initialize dependency injection');
    return GetIt.I.init(flavor);
  }

  static Future<void> reinitialize({required bool useTms}) async {
    Fimber.i('Reinitialize dependency injection with useTms=$useTms');
    final flavor = DI.get<Flavor>();
    final LogTree? logTree = getOrNull<LogTree>();
    if (logTree != null) {
      Fimber.d('Unplanting existing log tree');
      Fimber.unplantTree(logTree);
    }
    await GetIt.I.reset();
    GetIt.I.init(flavor);

    await GetIt.I.allReady();

    Fimber.plantTree(DI.get<LogTree>());
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
    BaseScope.push(flavor: flavor);
    SferaMockScope.push();
    await allReady();
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
}

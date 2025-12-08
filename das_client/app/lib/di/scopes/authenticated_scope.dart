import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:app/provider/ru_feature_provider_impl.dart';
import 'package:app/util/device_id_info.dart';
import 'package:auth/component.dart';
import 'package:formation/component.dart';
import 'package:get_it/get_it.dart';
import 'package:http_x/component.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

final _log = Logger('AuthenticatedScope');

class AuthenticatedScope extends DIScope {
  @override
  String get scopeName => 'AuthenticatedScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);

    getIt.registerAuthProvider();
    getIt.registerSferaAuthProvider();
    getIt.registerHttpClient();
    getIt.registerSferaAuthService();
    getIt.registerMqttAuthProvider();
    getIt.registerMqttService();
    getIt.registerSferaLocalRepo();
    getIt.registerSferaRemoteRepo();
    getIt.registerSettingsRepository();
    getIt.registerRuFeatureProvider();
    getIt.registerFormationRepository();

    await getIt.allReady();
  }
}

extension AuthenticatedScopeExtension on GetIt {
  void registerAuthProvider() {
    factoryFunc() {
      _log.fine('Register auth provider');
      return _AuthProvider(authenticator: DI.get());
    }

    registerFactory<AuthProvider>(factoryFunc);
  }

  void registerSferaAuthProvider() {
    factoryFunc() {
      _log.fine('Register sfera auth provider');
      return _SferaAuthProvider(authenticator: DI.get());
    }

    registerFactory<SferaAuthProvider>(factoryFunc);
  }

  void registerMqttAuthProvider() {
    factoryFunc() {
      _log.fine('Register mqtt auth provider');
      return _MqttAuthProvider(
        authenticator: DI.get(),
        sferaAuthService: DI.get(),
        oauthProfile: DI.get<Flavor>().mqttOauthProfile,
      );
    }

    registerFactory<MqttAuthProvider>(factoryFunc);
  }

  void registerMqttService() {
    Future<MqttService> factoryFunc() async {
      _log.fine('Register mqtt service');
      final flavor = DI.get<Flavor>();
      final deviceId = await DeviceIdInfo.getDeviceId();
      return MqttComponent.createMqttService(
        mqttUrl: flavor.mqttUrl,
        mqttClientConnector: DI.get(),
        prefix: flavor.mqttTopicPrefix,
        deviceId: deviceId,
      );
    }

    registerSingletonAsync(factoryFunc);
  }

  void registerHttpClient() {
    factoryFunc() {
      _log.fine('Register http client');
      return HttpXComponent.createHttpClient(authProvider: DI.get());
    }

    registerLazySingleton<Client>(factoryFunc);
  }

  void registerSferaAuthService() {
    factoryFunc() {
      _log.fine('Register sfera auth service');
      final flavor = DI.get<Flavor>();
      final httpClient = DI.get<Client>();
      return SferaComponent.createSferaAuthService(
        httpClient: httpClient,
        tokenExchangeUrl: flavor.tokenExchangeUrl,
      );
    }

    registerLazySingleton<SferaAuthService>(factoryFunc);
  }

  void registerSferaRemoteRepo() {
    factoryFunc() async {
      _log.fine('Register sfera remote repo');
      final deviceId = await DeviceIdInfo.getDeviceId();
      return SferaComponent.createSferaRemoteRepo(
        mqttService: DI.get(),
        sferaAuthProvider: DI.get(),
        deviceId: deviceId,
      );
    }

    registerSingletonAsync<SferaRemoteRepo>(
      factoryFunc,
      dispose: (repo) => repo.dispose(),
      dependsOn: [MqttService],
    );
  }

  void registerSferaLocalRepo() {
    factoryFunc() {
      _log.fine('Register sfera local repo');
      return SferaComponent.createSferaLocalRepo();
    }

    registerLazySingleton<SferaLocalRepo>(factoryFunc);
  }

  void registerSettingsRepository() {
    final flavor = DI.get<Flavor>();
    final configRepository = SettingsComponent.createRepository(baseUrl: flavor.backendUrl, client: DI.get());
    registerSingleton<SettingsRepository>(configRepository);
    registerSingleton<LogEndpoint>(configRepository);
  }

  void registerRuFeatureProvider() {
    factoryFunc() {
      return RuFeatureProviderImpl(sferaRemoteRepo: DI.get(), settingsRepository: DI.get());
    }

    registerLazySingleton<RuFeatureProvider>(factoryFunc);
  }

  void registerFormationRepository() {
    final flavor = DI.get<Flavor>();
    registerSingleton<FormationRepository>(
      FormationComponent.createRepository(baseUrl: flavor.backendUrl, client: DI.get()),
    );
  }
}

class _AuthProvider implements AuthProvider {
  const _AuthProvider({required this.authenticator});

  final Authenticator authenticator;

  @override
  Future<String> call({String? tokenId}) async {
    final oidcToken = await authenticator.token(tokenId: tokenId);
    final accessToken = oidcToken.accessToken;
    return '${oidcToken.tokenType} $accessToken';
  }
}

class _SferaAuthProvider implements SferaAuthProvider {
  const _SferaAuthProvider({required this.authenticator});

  final Authenticator authenticator;

  @override
  Future<bool> isDriver() async {
    final user = await authenticator.user();
    return user.roles.contains(Role.driver);
  }
}

class _MqttAuthProvider implements MqttAuthProvider {
  const _MqttAuthProvider({required this.authenticator, required this.sferaAuthService, required this.oauthProfile});

  final SferaAuthService sferaAuthService;
  final Authenticator authenticator;

  @override
  final String oauthProfile;

  @override
  Future<String?> tmsToken({required String company, required String train, required String role}) {
    return sferaAuthService.retrieveAuthToken(company, train, role);
  }

  @override
  Future<String> token() async {
    final token = await authenticator.token();
    return token.accessToken;
  }

  @override
  Future<String> userId() async {
    final user = await authenticator.user();
    return user.name;
  }
}

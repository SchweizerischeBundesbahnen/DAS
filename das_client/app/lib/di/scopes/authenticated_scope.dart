import 'package:app/app_info/app_info.dart';
import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:app/pages/journey/journey_screen/view_model/sfera_mock_customer_oriented_departure_repository_impl.dart';
import 'package:app/pages/journey/view_model/app_expiration_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:app/provider/ru_feature_provider_impl.dart';
import 'package:app/util/device_id_info.dart';
import 'package:auth/component.dart';
import 'package:customer_oriented_departure/component.dart';
import 'package:formation/component.dart';
import 'package:get_it/get_it.dart';
import 'package:http_x/component.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';
import 'package:preload/component.dart';
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

    final tmsScopeName = DI.get<TmsScope>().scopeName;
    final inTmsScope = getIt.hasScope(tmsScopeName);

    getIt.registerAuthProvider();
    getIt.registerSferaAuthProvider();
    getIt.registerHttpClient();
    getIt.registerMqttAuthProvider();
    getIt.registerMqttService();
    getIt.registerSferaRemoteRepository();
    getIt.registerSettingsRepository();
    getIt.registerCustomerOrientedDepartureRepository(inTmsScope: inTmsScope);
    getIt.registerAppExpirationViewModel();
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
        sferaVersion: flavor.sferaVersion,
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

  void registerSferaRemoteRepository() {
    factoryFunc() async {
      _log.fine('Register sfera remote repository');
      final flavor = DI.get<Flavor>();
      final deviceId = await DeviceIdInfo.getDeviceId();
      return SferaComponent.createSferaRepository(
        mqttService: DI.get(),
        sferaAuthProvider: DI.get(),
        localRepo: DI.get(),
        connectivityManager: DI.get(),
        deviceId: deviceId,
        authenticator: DI.get(),
        sferaVersion: flavor.sferaVersion,
      );
    }

    registerSingletonAsync<SferaRepository>(
      factoryFunc,
      dispose: (repo) => repo.dispose(),
      dependsOn: [MqttService],
    );
  }

  void registerSettingsRepository() {
    _log.fine('Register settings repository');
    final flavor = DI.get<Flavor>();
    final appVersion = DI.get<AppInfo>().version;

    final settingsRepository = SettingsComponent.createRepository(
      baseUrl: flavor.backendUrl,
      client: DI.get(),
      onAwsCredentialsChanged: (credentials) {
        DI.get<PreloadRepository>().updateConfiguration(credentials);
      },
      appVersion: appVersion,
    );

    registerSingleton<SettingsRepository>(settingsRepository);
    registerSingleton<LogEndpoint>(settingsRepository);
  }

  void registerAppExpirationViewModel() {
    final appVersion = DI.get<AppInfo>().version;
    final vm = AppExpirationViewModel(
      settingsRepository: DI.get<SettingsRepository>(),
      currentAppVersion: appVersion,
    );
    registerSingleton<AppExpirationViewModel>(vm, dispose: (vm) => vm.dispose());
  }

  void registerRuFeatureProvider() {
    factoryFunc() {
      return RuFeatureProviderImpl(sferaRepo: DI.get(), settingsRepository: DI.get());
    }

    registerLazySingleton<RuFeatureProvider>(factoryFunc);
  }

  void registerFormationRepository() {
    final flavor = DI.get<Flavor>();
    registerSingleton<FormationRepository>(
      FormationComponent.createRepository(baseUrl: flavor.backendUrl, client: DI.get()),
    );
  }

  void registerCustomerOrientedDepartureRepository({required bool inTmsScope}) {
    if (inTmsScope) {
      factoryFunc() async {
        _log.fine('Register customer oriented departure repository');
        final flavor = DI.get<Flavor>();
        final deviceId = await DeviceIdInfo.getDeviceId();
        return CustomerOrientedDepartureComponent.createRepository(
          baseUrl: flavor.backendUrl,
          client: DI.get(),
          deviceId: deviceId,
        );
      }

      registerSingletonAsync<CustomerOrientedDepartureRepository>(
        factoryFunc,
        dispose: (repo) => repo.dispose(),
      );
    } else {
      _log.fine('Register sfera mock customer oriented departure repository');
      final repository = SferaMockCustomerOrientedDepartureRepositoryImpl(
        sferaRepo: DI.get(),
        ruFeatureProvider: DI.get(),
      );

      registerSingleton<CustomerOrientedDepartureRepository>(
        repository,
        dispose: (repo) => repo.dispose(),
      );
    }
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
  const _MqttAuthProvider({required this.authenticator, required this.oauthProfile});

  final Authenticator authenticator;

  @override
  final String oauthProfile;

  @override
  Future<String> token() async {
    final token = await authenticator.token();
    return token.accessToken;
  }

  @override
  Future<String?> tid() async {
    final user = await authenticator.user();
    return user.tid;
  }

  @override
  Future<String> userId() async {
    final user = await authenticator.user();
    return user.userId;
  }
}

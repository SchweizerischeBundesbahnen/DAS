import 'package:app/app_info/app_info.dart';
import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/view_model/app_expiration_view_model.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/model/extended_train_identification.dart';
import 'package:app/pages/journey/view_model/warn_app_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:app/provider/ru_feature_provider_impl.dart';
import 'package:app/util/device_id_info.dart';
import 'package:auth/component.dart';
import 'package:formation/component.dart';
import 'package:get_it/get_it.dart';
import 'package:http_x/component.dart';
import 'package:local_regulations/component.dart';
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

    getIt.registerAuthProvider();
    getIt.registerSferaAuthProvider();
    getIt.registerHttpClient();
    getIt.registerMqttAuthProvider();
    await getIt.registerMqttService();
    await getIt.registerSferaRemoteRepo();
    getIt.registerSettingsRepository();
    getIt.registerAppExpirationViewModel();
    getIt.registerRuFeatureProvider();
    getIt.registerFormationRepository();

    getIt.registerJourneyNavigationViewModel();
    getIt.registerJourneySelectionViewModel();
    getIt.registerJourneyViewModel();
    getIt.registerNotificationPriorityViewModel();
    getIt.registerWarnAppViewModel();
    getIt.registerLocalRegulationHtmlGenerator();

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

  Future<void> registerMqttService() async {
    _log.fine('Register mqtt service');
    final flavor = DI.get<Flavor>();
    final deviceId = await DeviceIdInfo.getDeviceId();

    registerSingleton<MqttService>(
      MqttComponent.createMqttService(
        mqttUrl: flavor.mqttUrl,
        mqttClientConnector: DI.get(),
        prefix: flavor.mqttTopicPrefix,
        deviceId: deviceId,
        sferaVersion: flavor.sferaVersion,
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerHttpClient() {
    factoryFunc() {
      _log.fine('Register http client');
      return HttpXComponent.createHttpClient(authProvider: DI.get());
    }

    registerLazySingleton<Client>(factoryFunc);
  }

  Future<void> registerSferaRemoteRepo() async {
    _log.fine('Register sfera remote repo');
    final flavor = DI.get<Flavor>();
    final deviceId = await DeviceIdInfo.getDeviceId();

    registerSingleton<SferaRepository>(
      SferaComponent.createSferaRepository(
        mqttService: DI.get(),
        sferaAuthProvider: DI.get(),
        localRepo: DI.get(),
        connectivityManager: DI.get(),
        deviceId: deviceId,
        authenticator: DI.get(),
        sferaVersion: flavor.sferaVersion,
      ),
      dispose: (repo) => repo.dispose(),
    );
  }

  void registerSettingsRepository() {
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

  void registerJourneyNavigationViewModel() {
    factoryFunc() {
      _log.fine('Register JourneyNavigationViewModel');
      return JourneyNavigationViewModel(sferaRepo: DI.get());
    }

    registerLazySingleton<JourneyNavigationViewModel>(
      factoryFunc,
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneySelectionViewModel() {
    factoryFunc() {
      _log.fine('Register JourneySelectionViewModel');
      return JourneySelectionViewModel(
        sferaRepo: DI.get(),
        onJourneySelected: (trainId) => DI.get<JourneyNavigationViewModel>().replaceWith([
          ExtendedTrainIdentification(trainIdentification: trainId),
        ]),
      );
    }

    registerLazySingleton<JourneySelectionViewModel>(
      factoryFunc,
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneyViewModel() {
    registerSingleton(
      JourneyViewModel(sferaRepository: DI.get()),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerNotificationPriorityViewModel() {
    registerSingleton(
      NotificationPriorityQueueViewModel(),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerWarnAppViewModel() {
    registerSingleton(
      WarnAppViewModel(
        flavor: DI.get(),
        sferaRepo: DI.get(),
        warnappRepo: DI.get(),
        ruFeatureProvider: DI.get(),
        notificationViewModel: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerLocalRegulationHtmlGenerator() {
    registerSingleton(LocalRegulationComponent.createLocalRegulationHtmlGenerator());
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

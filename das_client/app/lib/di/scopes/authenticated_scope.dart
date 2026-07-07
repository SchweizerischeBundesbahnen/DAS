import 'package:app/app_info/app_info.dart';
import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:app/pages/journey/journey_screen/view_model/mock/sfera_mock_customer_oriented_departure_repository_impl.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/view_model/app_expiration_view_model.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/model/extended_train_identification.dart';
import 'package:app/pages/journey/view_model/sfera_journey_view_model.dart';
import 'package:app/pages/journey/view_model/view_mode_view_model.dart';
import 'package:app/pages/journey/view_model/warn_app_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:app/provider/ru_feature_provider_impl.dart';
import 'package:app/provider/timed_route_provider.dart';
import 'package:app/provider/timed_route_provider_impl.dart';
import 'package:app/provider/user_settings.dart';
import 'package:app/util/device_id_info.dart';
import 'package:auth/component.dart';
import 'package:customer_oriented_departure/component.dart';
import 'package:external_links/component.dart';
import 'package:formation/component.dart';
import 'package:get_it/get_it.dart';
import 'package:http_x/component.dart';
import 'package:local_regulations/component.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';
import 'package:preload/component.dart';
import 'package:ru_indications/component.dart';
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
    getIt.registerAppExpirationViewModel();
    getIt.registerRuFeatureProvider();
    getIt.registerFormationRepository();
    getIt.registerCustomerOrientedDepartureRepository(inTmsScope: inTmsScope);
    getIt.registerExternalLinksRepository();
    getIt.registerRuIndicationsRepository();
    getIt.registerTimedRouteProvider();

    getIt.registerSferaJourneyViewModel();
    getIt.registerJourneyViewModel();
    getIt.registerJourneyNavigationViewModel();
    getIt.registerJourneySelectionViewModel();
    getIt.registerNotificationPriorityViewModel();
    getIt.registerJourneySettingsViewModel();
    getIt.registerViewModeViewModel();
    getIt.registerWarnAppViewModel();
    getIt.registerLocalRegulationHtmlGenerator();

    await getIt.allReady();
  }
}

extension AuthenticatedScopeExtension on GetIt {
  void registerViewModeViewModel() {
    registerSingletonAsync<ViewModeViewModel>(
      () async => ViewModeViewModel(journeySettingsViewModel: DI.get()),
      dependsOn: [JourneySettingsViewModel],
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerAuthProvider() {
    registerSingleton<AuthProvider>(_AuthProvider(authenticator: DI.get()));
  }

  void registerSferaAuthProvider() {
    registerSingleton<SferaAuthProvider>(_SferaAuthProvider(authenticator: DI.get()));
  }

  void registerMqttAuthProvider() {
    registerSingleton<MqttAuthProvider>(
      _MqttAuthProvider(
        authenticator: DI.get(),
        oauthProfile: DI.get<Flavor>().mqttOauthProfile,
      ),
    );
  }

  void registerMqttService() {
    final flavor = DI.get<Flavor>();

    registerSingletonAsync<MqttService>(
      () async => MqttComponent.createMqttService(
        mqttUrl: flavor.mqttUrl,
        mqttClientConnector: DI.get(),
        prefix: flavor.mqttTopicPrefix,
        deviceId: await DeviceIdInfo.getDeviceId(),
        sferaVersion: flavor.sferaVersion,
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerHttpClient() {
    factoryFunc() {
      return HttpXComponent.createHttpClient(authProvider: DI.get());
    }

    registerLazySingleton<Client>(factoryFunc);
  }

  Future<void> registerSferaRemoteRepository() async {
    final flavor = DI.get<Flavor>();

    registerSingletonAsync<SferaRepository>(
      () async => SferaComponent.createSferaRepository(
        mqttService: DI.get(),
        sferaAuthProvider: DI.get(),
        localRepo: DI.get(),
        connectivityManager: DI.get(),
        deviceId: await DeviceIdInfo.getDeviceId(),
        authenticator: DI.get(),
        sferaVersion: flavor.sferaVersion,
      ),
      dependsOn: [MqttService],
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
    registerSingletonAsync<RuFeatureProvider>(
      () async => RuFeatureProviderImpl(
        sferaRepo: DI.get(),
        settingsRepository: DI.get(),
      ),
      dependsOn: [SferaRepository],
    );
  }

  void registerFormationRepository() {
    final flavor = DI.get<Flavor>();
    registerSingleton<FormationRepository>(
      FormationComponent.createRepository(baseUrl: flavor.backendUrl, client: DI.get()),
    );
  }

  void registerExternalLinksRepository() {
    final flavor = DI.get<Flavor>();
    final repo = ExternalLinksComponent.createRepository(baseUrl: flavor.backendUrl, client: DI.get());
    registerSingleton<ExternalLinksRepository>(repo);

    final companyCodes = DI
        .get<UserSettings>()
        .railwayUndertakings
        .map((undertaking) => undertaking.companyCode)
        .toList();
    repo.reloadExternalLinksByCompanies(companyCodes);
  }

  void registerRuIndicationsRepository() {
    final flavor = DI.get<Flavor>();
    registerSingleton<RuIndicationsRepository>(
      RuIndicationsComponent.createRepository(baseUrl: flavor.backendUrl, client: DI.get()),
    );
  }

  void registerJourneyNavigationViewModel() {
    registerSingletonAsync<JourneyNavigationViewModel>(
      () async => JourneyNavigationViewModel(sferaRepo: DI.get()),
      dependsOn: [SferaRepository],
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneySelectionViewModel() {
    factoryFunc() async {
      return JourneySelectionViewModel(
        sferaRepo: DI.get(),
        onJourneySelected: (trainId) => DI.get<JourneyNavigationViewModel>().replaceWith([
          ExtendedTrainIdentification(trainIdentification: trainId),
        ]),
      );
    }

    registerSingletonAsync<JourneySelectionViewModel>(
      factoryFunc,
      dependsOn: [SferaRepository, JourneyNavigationViewModel],
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneyViewModel() {
    registerSingletonAsync(
      () async => JourneyViewModel(
        sferaJourneyViewModel: DI.get(),
        ruIndicationsRepository: DI.get(),
      ),
      dependsOn: [SferaJourneyViewModel],
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerSferaJourneyViewModel() {
    registerSingletonAsync<SferaJourneyViewModel>(
      () async => SferaJourneyViewModel(sferaRepository: DI.get()),
      dependsOn: [SferaRepository],
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerNotificationPriorityViewModel() {
    registerSingletonAsync(
      () async => NotificationPriorityQueueViewModel(),
      dependsOn: [JourneyViewModel],
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerWarnAppViewModel() {
    registerSingletonAsync(
      () async => WarnAppViewModel(
        flavor: DI.get(),
        sferaRepo: DI.get(),
        warnappRepo: DI.get(),
        ruFeatureProvider: DI.get(),
        notificationViewModel: DI.get(),
      ),
      dependsOn: [
        SferaRepository,
        RuFeatureProvider,
        NotificationPriorityQueueViewModel,
      ],
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneySettingsViewModel() {
    registerSingletonAsync<JourneySettingsViewModel>(
      () async => JourneySettingsViewModel(),
      dependsOn: [JourneyViewModel],
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerLocalRegulationHtmlGenerator() {
    registerSingleton(LocalRegulationComponent.createLocalRegulationHtmlGenerator());
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
      factoryFunc() async {
        _log.fine('Register sfera mock customer oriented departure repository');
        return SferaMockCustomerOrientedDepartureRepositoryImpl(
          sferaRepo: DI.get(),
          ruFeatureProvider: DI.get(),
        );
      }

      registerSingletonAsync<CustomerOrientedDepartureRepository>(
        dependsOn: [SferaRepository, RuFeatureProvider],
        factoryFunc,
        dispose: (repo) => repo.dispose(),
      );
    }
  }

  void registerTimedRouteProvider() {
    registerSingleton<TimedRouteProvider>(TimedRouteProviderImpl());
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

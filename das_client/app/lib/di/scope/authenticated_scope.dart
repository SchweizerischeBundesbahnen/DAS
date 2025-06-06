import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:app/util/device_id_info.dart';
import 'package:auth/component.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:http_x/component.dart';
import 'package:mqtt/component.dart';
import 'package:sfera/component.dart';

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
    _getIt.registerTrainJourneyViewModel();

    return _getIt.allReady();
  }

  Future<void> pop() async {
    Fimber.d('Popping scope $_scopeName');
    await _getIt.popScopesTill(_scopeName);
  }
}

extension AuthenticatedScopeExtension on GetIt {
  void registerAuthProvider() {
    factoryFunc() {
      Fimber.d('Register auth provider');
      return _AuthProvider(authenticator: DI.get());
    }

    registerFactory<AuthProvider>(factoryFunc);
  }

  void registerSferaAuthProvider() {
    factoryFunc() {
      Fimber.d('Register sfera auth provider');
      return _SferaAuthProvider(authenticator: DI.get());
    }

    registerFactory<SferaAuthProvider>(factoryFunc);
  }

  void registerMqttAuthProvider() {
    factoryFunc() {
      Fimber.d('Register mqtt auth provider');
      return _MqttAuthProvider(authenticator: DI.get(), sferaAuthService: DI.get());
    }

    registerFactory<MqttAuthProvider>(factoryFunc);
  }

  void registerMqttService() {
    Future<MqttService> factoryFunc() async {
      Fimber.d('Register mqtt service');
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

  void registerSferaAuthService() {
    factoryFunc() {
      Fimber.d('Register sfera auth service');
      final flavor = DI.get<Flavor>();
      final httpClient = HttpXComponent.createHttpClient(authProvider: DI.get());
      return SferaComponent.createSferaAuthService(
        httpClient: httpClient,
        tokenExchangeUrl: flavor.tokenExchangeUrl,
      );
    }

    registerLazySingleton<SferaAuthService>(factoryFunc);
  }

  void registerSferaRemoteRepo() {
    factoryFunc() async {
      Fimber.d('Register sfera remote repo');
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
      Fimber.d('Register sfera local repo');
      return SferaComponent.createSferaLocalRepo();
    }

    registerLazySingleton<SferaLocalRepo>(factoryFunc);
  }

  void registerTrainJourneyViewModel() {
    factoryFunc() {
      Fimber.d('Register TrainJourneyViewModel');
      return TrainJourneyViewModel(sferaRemoteRepo: DI.get());
    }

    registerLazySingleton<TrainJourneyViewModel>(
      factoryFunc,
      dispose: (vm) => vm.dispose(),
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
  const _MqttAuthProvider({required this.authenticator, required this.sferaAuthService});

  final SferaAuthService sferaAuthService;
  final Authenticator authenticator;

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

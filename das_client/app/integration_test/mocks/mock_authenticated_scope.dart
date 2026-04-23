// implement the mock for authenticated_scope.dart

import 'package:app/di/di.dart';
import 'package:app/di/scopes/authenticated_scope.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:formation/component.dart';
import 'package:logging/logging.dart';
import 'package:preload/component.dart';

import 'mock_formation_repository.dart';
import 'mock_preload_repository.dart';
import 'mock_ru_feature_provider.dart';

final _log = Logger('MockAuthenticatedScope');

class MockAuthenticatedScope extends AuthenticatedScope {
  MockAuthenticatedScope(this.e2e);

  final bool e2e;

  @override
  String get scopeName => 'MockAuthenticatedScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing mock scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);

    getIt.registerAuthProvider();
    getIt.registerSferaAuthProvider();
    getIt.registerMqttAuthProvider();
    getIt.registerMqttService();
    getIt.registerHttpClient();
    getIt.registerSferaLocalRepo();
    getIt.registerSferaRemoteRepo();
    if (e2e) {
      getIt.registerSettingsRepositoryAsync();
      getIt.registerPreloadRepository();
      getIt.registerRuFeatureProvider();
      getIt.registerFormationRepository();
    } else {
      _registerMockPreloadRepository();
      _registerMockRuFeaturesProvider();
      _registerMockFormationRepository();
    }
    getIt.registerAppExpirationViewModelAsync();

    return getIt.allReady();
  }

  void _registerMockRuFeaturesProvider() {
    getIt.registerSingleton<RuFeatureProvider>(MockRuFeatureProvider());
  }

  void _registerMockFormationRepository() {
    getIt.registerSingleton<FormationRepository>(MockFormationRepository());
  }

  void _registerMockPreloadRepository() {
    getIt.registerSingleton<PreloadRepository>(MockPreloadRepository());
  }
}

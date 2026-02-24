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
    getIt.registerSferaAuthService();
    getIt.registerSferaLocalRepo();
    getIt.registerSferaRemoteRepo();
    getIt.registerSettingsRepository();
    _registerMockRuFeaturesProvider();
    _registerMockFormationRepository();
    _registerMockPreloadRepository();

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

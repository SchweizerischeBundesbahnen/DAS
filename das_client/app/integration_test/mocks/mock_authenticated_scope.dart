// implement the mock for authenticated_scope.dart

import 'package:app/di/di.dart';
import 'package:app/pages/journey/view_model/warn_app_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:formation/component.dart';
import 'package:logging/logging.dart';

import 'mock_formation_repository.dart';
import 'mock_ru_feature_provider.dart';
import 'mock_warn_app_view_model.dart';

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
    getIt.registerHttpClient();
    getIt.registerMqttAuthProvider();
    await getIt.registerMqttService();
    await getIt.registerSferaRemoteRepo();
    getIt.registerAppExpirationViewModel();
    if (e2e) {
      getIt.registerSettingsRepository();
      getIt.registerRuFeatureProvider();
      getIt.registerFormationRepository();
    } else {
      _registerMockRuFeaturesProvider();
      _registerMockFormationRepository();
    }

    getIt.registerJourneyNavigationViewModel();
    getIt.registerJourneySelectionViewModel();
    getIt.registerJourneyViewModel();
    getIt.registerJourneySettingsViewModel();
    getIt.registerViewModeViewModel();
    getIt.registerNotificationPriorityViewModel();
    _registerMockWarnAppViewModel();
    getIt.registerLocalRegulationHtmlGenerator();

    return getIt.allReady();
  }

  void _registerMockRuFeaturesProvider() {
    getIt.registerSingleton<RuFeatureProvider>(MockRuFeatureProvider());
  }

  void _registerMockFormationRepository() {
    getIt.registerSingleton<FormationRepository>(MockFormationRepository());
  }

  void _registerMockWarnAppViewModel() {
    getIt.registerSingleton<WarnAppViewModel>(
      MockWarnAppViewModel(
        flavor: DI.get(),
        sferaRepo: DI.get(),
        warnappRepo: DI.get(),
        ruFeatureProvider: DI.get(),
        notificationViewModel: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }
}

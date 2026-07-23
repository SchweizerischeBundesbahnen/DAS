// implement the mock for authenticated_scope.dart

import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/sim_train_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/warn_app_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:customer_oriented_departure/component.dart';
import 'package:external_links/component.dart';
import 'package:formation/component.dart';
import 'package:logging/logging.dart';
import 'package:ru_indications/component.dart';
import 'package:train_identification/component.dart';
import 'package:sfera/component.dart';

import 'mock_customer_oriented_departure_repository.dart';
import 'mock_external_links_repository.dart';
import 'mock_formation_repository.dart';
import 'mock_ru_feature_provider.dart';
import 'mock_ru_indications_repository.dart';
import 'mock_train_identification_repository.dart';
import 'mock_sim_train_view_model.dart';
import 'mock_warn_app_view_model.dart';

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
    getIt.registerHttpClient();
    getIt.registerMqttAuthProvider();
    getIt.registerMqttService();
    getIt.registerSferaRemoteRepository();
    getIt.registerAppExpirationViewModel();
    _registerMockRuFeaturesProvider();
    _registerMockFormationRepository();
    _registerMockRuIndicationsRepository();
    _registerMockTrainIdentificationRepository();
    _registerMockCustomerOrientedDepartureRepository();
    getIt.registerTimedRouteProvider();

    getIt.registerSferaJourneyViewModel();
    getIt.registerJourneyViewModel();
    getIt.registerJourneyNavigationViewModel();
    getIt.registerJourneySelectionViewModel();
    getIt.registerNotificationPriorityViewModel();
    getIt.registerJourneySettingsViewModel();
    getIt.registerViewModeViewModel();
    _registerMockWarnAppViewModel();
    _registerMockExternalLinksRepository();
    _registerMockSimTrainViewModel();

    getIt.registerLocalRegulationHtmlGenerator();

    return getIt.allReady();
  }

  void _registerMockRuFeaturesProvider() {
    getIt.registerSingletonAsync<RuFeatureProvider>(() async => MockRuFeatureProvider());
  }

  void _registerMockFormationRepository() {
    getIt.registerSingleton<FormationRepository>(MockFormationRepository());
  }

  void _registerMockRuIndicationsRepository() {
    getIt.registerSingleton<RuIndicationsRepository>(MockRuIndicationsRepository());
  }

  void _registerMockTrainIdentificationRepository() {
    getIt.registerSingleton<TrainIdentificationRepository>(MockTrainIdentificationRepository());
  }

  void _registerMockExternalLinksRepository() {
    getIt.registerSingleton<ExternalLinksRepository>(MockExternalLinksRepository());
  }

  void _registerMockWarnAppViewModel() {
    getIt.registerSingletonAsync<WarnAppViewModel>(
      () async => MockWarnAppViewModel(
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

  void _registerMockCustomerOrientedDepartureRepository() {
    getIt.registerSingletonAsync<CustomerOrientedDepartureRepository>(
      () async => MockCustomerOrientedDepartureRepository(),
      dispose: (repo) => repo.dispose(),
    );
  }

  void _registerMockSimTrainViewModel() {
    getIt.registerSingletonAsync<SimTrainViewModel>(
      () async => MockSimTrainViewModel(),
      dependsOn: [JourneyViewModel],
      dispose: (vm) {
        if (vm is MockSimTrainViewModel) vm.closeMock();
      },
    );
  }
}

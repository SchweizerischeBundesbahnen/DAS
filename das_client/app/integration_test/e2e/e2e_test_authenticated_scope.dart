import 'package:app/di/di.dart';
import 'package:customer_oriented_departure/component.dart';
import 'package:logging/logging.dart';

import '../mocks/mock_customer_oriented_departure_repository.dart';

final _log = Logger('E2ETestAuthenticatedScope');

class E2ETestAuthenticatedScope extends AuthenticatedScope {
  @override
  String get scopeName => 'E2ETestAuthenticatedScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);

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
    _registerMockCustomerOrientedDepartureRepository();
    getIt.registerExternalLinksRepository();
    getIt.registerRuIndicationsRepository();
    getIt.registerTrainIdentificationRepository();
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

  void _registerMockCustomerOrientedDepartureRepository() {
    getIt.registerSingletonAsync<CustomerOrientedDepartureRepository>(
      () async => MockCustomerOrientedDepartureRepository(),
      dispose: (repo) => repo.dispose(),
    );
  }
}

import 'package:app/di/scopes/journey_scope.dart';
import 'package:logging/logging.dart';

final _log = Logger('IntegrationTestJourneyScope');

class IntegrationTestJourneyScope extends JourneyScope {
  @override
  String get scopeName => 'IntegrationTestJourneyScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);

    getIt.registerCustomerOrientedDepartureViewModel();
    getIt.registerUxTestingViewModel();
    getIt.registerSferaDelayViewModel();
    getIt.registerJourneyPositionViewModel();
    getIt.registerPlannedTimeDelayViewModel();
    getIt.registerDepartureProcessWarningViewModel();
    getIt.registerDecisiveGradientViewModel();
    getIt.registerJourneyTableScrollController();
    getIt.registerDisturbanceViewModel();
    getIt.registerChecklistDepartureProcessViewModel();
    getIt.registerReplacementSeriesViewModel();
    getIt.registerDepartureDispatchNotificationViewModel();
    getIt.registerShortTermChangeViewModel();
    getIt.registerSuspiciousSegmentViewModel();
    getIt.registerLineSpeedViewModel();
    getIt.registerCalculatedSpeedViewModel();
    getIt.registerAdvisedSpeedViewModel();
    getIt.registerChronographViewModel();
    getIt.registerDetailModalViewModel();
    getIt.registerBrakeLoadSlipViewModel();
    // gets registered inside authenticated scope in tests to access before loading journey
    // getIt.registerSimTrainViewModel();
    getIt.registerCollapsibleRowsViewModel();
    getIt.registerJourneyTableViewModel();
    getIt.registerJourneyTableAdvancementViewModel();
    getIt.registerServicePointModalViewModel();

    await getIt.allReady();
  }
}

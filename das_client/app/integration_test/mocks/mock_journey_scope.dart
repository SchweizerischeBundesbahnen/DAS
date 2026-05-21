import 'package:app/di/scopes/journey_scope.dart';
import 'package:logging/logging.dart';

final _log = Logger('MockJourneyScope');

class MockJourneyScope extends JourneyScope {
  @override
  String get scopeName => 'MockJourneyScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing mock scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);

    getIt.registerUxTestingViewModel();
    getIt.registerPunctualityViewModel();
    getIt.registerJourneyPositionViewModel();
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
    getIt.registerCollapsibleRowsViewModel();
    getIt.registerJourneyTableViewModel();
    getIt.registerJourneyTableAdvancementViewModel();
    getIt.registerCustomerOrientedDepartureViewModel();

    return getIt.allReady();
  }
}

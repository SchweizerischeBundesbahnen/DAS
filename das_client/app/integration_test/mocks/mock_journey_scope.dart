import 'package:app/di/scopes/journey_scope.dart';
import 'package:app/pages/journey/journey_screen/view_model/sim_train_view_model.dart';
import 'package:logging/logging.dart';

import 'mock_sim_train_view_model.dart';

final _log = Logger('MockJourneyScope');

class MockJourneyScope extends JourneyScope {
  @override
  String get scopeName => 'MockJourneyScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing mock scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);

    getIt.registerCustomerOrientedDepartureViewModel();
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
    _registerMockSimTrainViewModel();
    getIt.registerCollapsibleRowsViewModel();
    getIt.registerJourneyTableViewModel();
    getIt.registerJourneyTableAdvancementViewModel();
    getIt.registerServicePointModalViewModel();

    return getIt.allReady();
  }

  void _registerMockSimTrainViewModel() {
    final mock = MockSimTrainViewModel();
    getIt.registerSingleton<SimTrainViewModel>(
      mock,
      dispose: (vm) {
        if (vm is MockSimTrainViewModel) {
          vm.closeMock();
        }
      },
    );
  }
}

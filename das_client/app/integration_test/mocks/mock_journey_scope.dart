import 'package:app/di/di.dart';
import 'package:app/di/scopes/journey_scope.dart';
import 'package:app/pages/journey/warn_app_view_model.dart';
import 'package:logging/logging.dart';

import 'mock_warn_app_view_model.dart';

final _log = Logger('MockJourneyScope');

class MockJourneyScope extends JourneyScope {
  @override
  String get scopeName => 'MockJourneyScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing mock scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);

    getIt.registerJourneyNavigationViewModel();
    getIt.registerJourneySelectionViewModel();
    getIt.registerJourneyTableViewModel();
    getIt.registerJourneySettingsViewModel();
    getIt.registerPunctualityViewModel();
    getIt.registerJourneyPositionViewModel();
    getIt.registerLocalRegulationHtmlGenerator();
    _registerMockWarnAppViewModel();

    return getIt.allReady();
  }

  void _registerMockWarnAppViewModel() {
    getIt.registerSingleton<WarnAppViewModel>(
      MockWarnAppViewModel(
        flavor: DI.get(),
        sferaRemoteRepo: DI.get(),
        warnappRepo: DI.get(),
        ruFeatureProvider: DI.get(),
      ),
    );
  }
}

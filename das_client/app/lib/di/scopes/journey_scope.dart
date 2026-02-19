import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_advancement_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/punctuality_view_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_table_view_model.dart';
import 'package:app/pages/journey/view_model/warn_app_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:local_regulations/component.dart';
import 'package:logging/logging.dart';

final _log = Logger('JourneyScope');

class JourneyScope extends DIScope {
  @override
  String get scopeName => 'JourneyScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);
    getIt.registerJourneyNavigationViewModel();
    getIt.registerJourneySelectionViewModel();
    getIt.registerJourneyTableViewModel();
    getIt.registerNotificationPriorityViewModel();
    getIt.registerJourneySettingsViewModel();
    getIt.registerPunctualityViewModel();
    getIt.registerJourneyPositionViewModel();
    getIt.registerJourneyTableAdvancementViewModel();
    getIt.registerWarnAppViewModel();
    getIt.registerLocalRegulationHtmlGenerator();
  }
}

extension JourneyScopeExtension on GetIt {
  void registerJourneyNavigationViewModel() {
    factoryFunc() {
      _log.fine('Register JourneyNavigationViewModel');
      return JourneyNavigationViewModel(sferaRepo: DI.get());
    }

    registerLazySingleton<JourneyNavigationViewModel>(
      factoryFunc,
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneySelectionViewModel() {
    factoryFunc() {
      _log.fine('Register JourneySelectionViewModel');
      return JourneySelectionViewModel(
        sferaRepo: DI.get(),
        onJourneySelected: DI.get<JourneyNavigationViewModel>().push,
      );
    }

    registerLazySingleton<JourneySelectionViewModel>(
      factoryFunc,
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneyTableViewModel() {
    registerSingleton(
      JourneyTableViewModel(sferaRepo: DI.get()),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerNotificationPriorityViewModel() {
    registerSingleton(
      NotificationPriorityQueueViewModel(),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneySettingsViewModel() {
    registerSingleton<JourneySettingsViewModel>(
      JourneySettingsViewModel(),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerPunctualityViewModel() {
    registerSingleton<PunctualityViewModel>(
      PunctualityViewModel(),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneyPositionViewModel() {
    registerSingleton<JourneyPositionViewModel>(
      JourneyPositionViewModel(
        punctualityStream: get<PunctualityViewModel>().model,
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneyTableAdvancementViewModel() {
    final journeyTableVM = DI.get<JourneyTableViewModel>();
    final settingsVM = DI.get<JourneySettingsViewModel>();
    final positionVM = DI.get<JourneyPositionViewModel>();
    final vm = JourneyTableAdvancementViewModel(
      journeyTableViewModel: journeyTableVM,
      positionStream: positionVM.model,
      scrollController: journeyTableVM.journeyTableScrollController,
      onAdvancementModeChanged: [journeyTableVM.updateZenViewMode, positionVM.onAdvancementModeChanged],
    );
    settingsVM.registerOnBreakSeriesUpdated(vm.scrollToCurrentPositionIfNotPaused);
    registerSingleton<JourneyTableAdvancementViewModel>(
      vm,
      dispose: (vm) {
        DI.get<JourneySettingsViewModel>().unregisterOnBreakSeriesUpdated(vm.scrollToCurrentPositionIfNotPaused);
        vm.dispose();
      },
    );
  }

  void registerWarnAppViewModel() {
    final vm = WarnAppViewModel(
      flavor: DI.get(),
      sferaRepo: DI.get(),
      warnappRepo: DI.get(),
      ruFeatureProvider: DI.get(),
    );
    final notificationVM = DI.get<NotificationPriorityQueueViewModel>();
    notificationVM.addStream(
      type: .maneuverMode,
      stream: vm.isManeuverModeEnabled,
    );
    registerSingleton(
      vm,
      dispose: (vm) {
        DI.get<NotificationPriorityQueueViewModel>().removeStream(type: .maneuverMode);
        vm.dispose();
      },
    );
  }

  void registerLocalRegulationHtmlGenerator() {
    registerSingleton(LocalRegulationComponent.createLocalRegulationHtmlGenerator());
  }
}

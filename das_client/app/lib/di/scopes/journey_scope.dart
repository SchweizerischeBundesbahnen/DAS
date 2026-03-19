import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/journey_table_scroll_controller.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_advancement_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/punctuality_view_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/view_mode_view_model.dart';
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
    getIt.registerViewModeViewModel();
    getIt.registerJourneyNavigationViewModel();
    getIt.registerJourneySelectionViewModel();
    getIt.registerJourneyViewModel();
    getIt.registerNotificationPriorityViewModel();
    getIt.registerJourneySettingsViewModel();
    getIt.registerPunctualityViewModel();
    getIt.registerJourneyPositionViewModel();
    getIt.registerJourneyTableScrollController();
    getIt.registerJourneyTableAdvancementViewModel();
    getIt.registerWarnAppViewModel();
    getIt.registerLocalRegulationHtmlGenerator();
  }
}

extension JourneyScopeExtension on GetIt {
  void registerViewModeViewModel() {
    factoryFunc() {
      _log.fine('Register ViewModeViewModel');
      return ViewModeViewModel();
    }

    registerLazySingleton<ViewModeViewModel>(
      factoryFunc,
      dispose: (vm) => vm.dispose(),
    );
  }

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
        onJourneySelected: (trainId) => DI.get<JourneyNavigationViewModel>().replaceWith([trainId]),
      );
    }

    registerLazySingleton<JourneySelectionViewModel>(
      factoryFunc,
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneyViewModel() {
    registerSingleton(
      JourneyViewModel(sferaRepository: DI.get()),
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
    final journeyVM = DI.get<JourneyViewModel>();
    final settingsVM = DI.get<JourneySettingsViewModel>();
    final positionVM = DI.get<JourneyPositionViewModel>();
    final viewModeVM = DI.get<ViewModeViewModel>();
    final vm = JourneyTableAdvancementViewModel(
      journeyViewModel: journeyVM,
      positionStream: positionVM.model,
      scrollController: DI.get<JourneyTableScrollController>(),
      onAdvancementModeChanged: [viewModeVM.updateZenViewMode, positionVM.onAdvancementModeChanged],
    );
    settingsVM.registerOnBrakeSeriesUpdated(vm.scrollToCurrentPositionIfNotPaused);
    registerSingleton<JourneyTableAdvancementViewModel>(
      vm,
      dispose: (vm) {
        DI.get<JourneySettingsViewModel>().unregisterOnBrakeSeriesUpdated(vm.scrollToCurrentPositionIfNotPaused);
        vm.dispose();
      },
    );
  }

  void registerJourneyTableScrollController() {
    registerSingleton(JourneyTableScrollController(), dispose: (controller) => controller.dispose());
  }

  void registerWarnAppViewModel() {
    registerSingleton(
      WarnAppViewModel(
        flavor: DI.get(),
        sferaRepo: DI.get(),
        warnappRepo: DI.get(),
        ruFeatureProvider: DI.get(),
        notificationViewModel: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerLocalRegulationHtmlGenerator() {
    registerSingleton(LocalRegulationComponent.createLocalRegulationHtmlGenerator());
  }
}

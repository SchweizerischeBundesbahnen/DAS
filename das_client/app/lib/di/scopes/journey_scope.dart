import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_table/punctuality/punctuality_view_model.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:app/pages/journey/navigation/journey_navigation_view_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/settings/journey_settings_view_model.dart';
import 'package:app/pages/journey/warn_app_view_model.dart';
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
    getIt.registerJourneySettingsViewModel();
    getIt.registerPunctualityViewModel();
    getIt.registerJourneyPositionViewModel();
    getIt.registerWarnAppViewModel();
    getIt.registerLocalRegulationHtmlGenerator();
  }
}

// TODO: You have the general problem that things are not persisted when navigating - one of these things is the state of advancement

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
        sferaRemoteRepo: DI.get(),
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
      JourneyTableViewModel(sferaRemoteRepo: DI.get()),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneySettingsViewModel() {
    registerSingleton<JourneySettingsViewModel>(
      JourneySettingsViewModel(journeyStream: get<JourneyTableViewModel>().journey),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerPunctualityViewModel() {
    registerSingleton<PunctualityViewModel>(
      PunctualityViewModel(journeyStream: get<JourneyTableViewModel>().journey),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneyPositionViewModel() {
    registerSingleton<JourneyPositionViewModel>(
      JourneyPositionViewModel(
        journeyStream: get<JourneyTableViewModel>().journey,
        punctualityStream: get<PunctualityViewModel>().model,
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerWarnAppViewModel() {
    registerSingleton(
      WarnAppViewModel(flavor: DI.get(), sferaRemoteRepo: DI.get(), warnappRepo: DI.get(), ruFeatureProvider: DI.get()),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerLocalRegulationHtmlGenerator() {
    registerSingleton(LocalRegulationComponent.createLocalRegulationHtmlGenerator());
  }
}

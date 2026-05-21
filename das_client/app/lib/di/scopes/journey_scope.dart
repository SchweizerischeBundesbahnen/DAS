import 'package:app/di/di.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/chronograph_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/short_term_change_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/suspicious_segment_view_model.dart';
import 'package:app/pages/journey/journey_screen/journey_table_scroll_controller.dart';
import 'package:app/pages/journey/journey_screen/view_model/advised_speed_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/calculated_speed_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/checklist_departure_process_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/departure_dispatch_notification_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/departure_process_warning_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_advancement_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/line_speed_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/chevron_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_table_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/replacement_series_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/punctuality_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/replacement_series_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/ux_testing_view_model.dart';
import 'package:app/pages/journey/view_model/decisive_gradient_view_model.dart';
import 'package:app/pages/journey/view_model/disturbance_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

final _log = Logger('JourneyScope');

class JourneyScope extends DIScope {
  @override
  String get scopeName => 'JourneyScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing scope $scopeName');
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
    getIt.registerServicePointModalViewModel();

    await getIt.allReady();
  }
}

extension JourneyScopeExtension on GetIt {
  void registerPunctualityViewModel() {
    registerSingleton<PunctualityViewModel>(
      PunctualityViewModel(journeyViewModel: DI.get()),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneyPositionViewModel() {
    registerSingleton<JourneyPositionViewModel>(
      JourneyPositionViewModel(
        punctualityStream: get<PunctualityViewModel>().model,
        journeySettingsViewModel: DI.get(),
        journeyViewModel: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneyTableScrollController() {
    registerSingleton(JourneyTableScrollController(), dispose: (controller) => controller.dispose());
  }

  void registerDepartureProcessWarningViewModel() {
    registerSingleton<DepartureProcessWarningViewModel>(
      DepartureProcessWarningViewModel(
        ruFeatureProvider: DI.get(),
        journeyViewModel: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerDecisiveGradientViewModel() {
    registerSingleton<DecisiveGradientViewModel>(
      DecisiveGradientViewModel(),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerDisturbanceViewModel() {
    registerSingleton<DisturbanceViewModel>(
      DisturbanceViewModel(sferaRepo: DI.get(), notificationVM: DI.get()),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerChecklistDepartureProcessViewModel() {
    registerSingleton<ChecklistDepartureProcessViewModel>(
      ChecklistDepartureProcessViewModel(
        journeyPositionViewModel: DI.get(),
        ruFeatureProvider: DI.get(),
        uxTestingViewModel: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerReplacementSeriesViewModel() {
    final vm = ReplacementSeriesViewModel(
      journeyPositionViewModel: DI.get(),
      journeySettingsViewModel: DI.get(),
      journeyViewModel: DI.get(),
    );
    final notificationVM = DI.get<NotificationPriorityQueueViewModel>();
    notificationVM.addStream(
      type: .illegalSegmentNoReplacement,
      stream: vm.model.map((m) => m is NoReplacementSeries),
    );
    notificationVM.addStream(
      type: .illegalSegmentWithReplacement,
      stream: vm.model.map((m) => m is ReplacementSeriesAvailable || m is OriginalSeriesAvailable),
    );

    registerSingleton<ReplacementSeriesViewModel>(
      vm,
      dispose: (vm) {
        notificationVM.removeStream(type: .illegalSegmentNoReplacement);
        notificationVM.removeStream(type: .illegalSegmentWithReplacement);
        vm.dispose();
      },
    );
  }

  void registerDepartureDispatchNotificationViewModel() {
    registerSingleton<DepartureDispatchNotificationViewModel>(
      DepartureDispatchNotificationViewModel(
        sferaRepo: DI.get(),
        journeyPositionStream: DI.get<JourneyPositionViewModel>().model,
        notificationVM: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerShortTermChangeViewModel() {
    registerSingleton<ShortTermChangeViewModel>(
      ShortTermChangeViewModel(journeyViewModel: DI.get(), journeyPositionViewModel: DI.get()),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerSuspiciousSegmentViewModel() {
    registerSingleton<SuspiciousSegmentViewModel>(
      SuspiciousSegmentViewModel(
        journeyViewModel: DI.get(),
        journeyPositionViewModel: DI.get(),
        notificationVM: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerLineSpeedViewModel() {
    registerSingleton<LineSpeedViewModel>(
      LineSpeedViewModel(
        journeyViewModel: DI.get(),
        journeySettingsViewModel: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerAdvisedSpeedViewModel() {
    registerSingleton<AdvisedSpeedViewModel>(
      AdvisedSpeedViewModel(
        journeyViewModel: DI.get(),
        notificationVM: DI.get(),
        journeyPositionStream: DI.get<JourneyPositionViewModel>().model,
        lineSpeedViewModel: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerChronographViewModel() {
    registerSingleton<ChronographViewModel>(
      ChronographViewModel(
        journeyViewModel: DI.get(),
        journeyPositionStream: DI.get<JourneyPositionViewModel>().model,
        punctualityStream: DI.get<PunctualityViewModel>().model,
        advisedSpeedModelStream: DI.get<AdvisedSpeedViewModel>().model,
        calculatedSpeedViewModel: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerCalculatedSpeedViewModel() {
    registerSingleton<CalculatedSpeedViewModel>(
      CalculatedSpeedViewModel(
        journeyViewModel: DI.get(),
        lineSpeedViewModel: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerDetailModalViewModel() {
    registerSingleton<DetailModalViewModel>(
      DetailModalViewModel(),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerBrakeLoadSlipViewModel() {
    registerSingleton<BrakeLoadSlipViewModel>(
      BrakeLoadSlipViewModel(
        journeyViewModel: DI.get(),
        formationRepository: DI.get(),
        journeyPositionViewModel: DI.get(),
        journeySettingsViewModel: DI.get(),
        notificationViewModel: DI.get(),
        detailModalViewModel: DI.get(),
        connectivityManager: DI.get(),
        checkForUpdates: true,
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerCollapsibleRowsViewModel() {
    registerSingleton<CollapsibleRowsViewModel>(
      CollapsibleRowsViewModel(
        journeyViewModel: DI.get(),
        formationRunStream: DI.get<BrakeLoadSlipViewModel>().formationRun,
        journeyPositionStream: DI.get<JourneyPositionViewModel>().model,
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerUxTestingViewModel() {
    registerSingleton<UxTestingViewModel>(
      UxTestingViewModel(
        sferaRepo: DI.get(),
        ruFeatureProvider: DI.get(),
        formationRepository: DI.get(),
        notificationViewModel: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneyTableViewModel() {
    registerSingleton<JourneyTableViewModel>(
      JourneyTableViewModel(
        journeyViewModel: DI.get(),
        settingsVM: DI.get(),
        collapsibleRowsVM: DI.get(),
        positionVM: DI.get(),
        detailModalVM: DI.get(),
        decisiveGradientVM: DI.get(),
        navigationVM: DI.get(),
        userSettings: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerJourneyTableAdvancementViewModel() {
    final chevronStream = DI.get<JourneyTableViewModel>().model.map<ChevronPositionModel>(
      (item) => item is TableLoaded ? item.chevronPosition : ChevronPositionModel(),
    );

    registerSingleton<JourneyTableAdvancementViewModel>(
      JourneyTableAdvancementViewModel(
        journeyViewModel: DI.get(),
        chevronPositionStream: chevronStream,
        scrollController: DI.get(),
        journeySettingsViewModel: DI.get(),
        detailModalViewModel: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }

  void registerServicePointModalViewModel() {
    registerSingleton<ServicePointModalViewModel>(
      ServicePointModalViewModel(
        journeyViewModel: DI.get(),
        localRegulationHtmlGenerator: DI.get(),
        settingsVM: DI.get(),
      ),
      dispose: (vm) => vm.dispose(),
    );
  }
}

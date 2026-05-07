import 'dart:async';

import 'package:app/extension/base_data_extension.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_table_model.dart';
import 'package:app/pages/journey/view_model/decisive_gradient_view_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/model/journey_navigation_model.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:app/provider/user_settings.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyTableViewModel');

class JourneyTableViewModel extends JourneyAwareViewModel {
  JourneyTableViewModel({
    required super.journeyViewModel,
    required JourneySettingsViewModel settingsVM,
    required CollapsibleRowsViewModel collapsibleRowsVM,
    required JourneyPositionViewModel positionVM,
    required DetailModalViewModel detailModalVM,
    required DecisiveGradientViewModel decisiveGradientVM,
    required JourneyNavigationViewModel navigationVM,
    required UserSettings userSettings,
  }) : _settingsVM = settingsVM,
       _collapsibleRowsVM = collapsibleRowsVM,
       _positionVM = positionVM,
       _detailModalVM = detailModalVM,
       _decisiveGradientVM = decisiveGradientVM,
       _navigationVM = navigationVM,
       _userSettings = userSettings {
    _init();
  }

  final JourneySettingsViewModel _settingsVM;
  final CollapsibleRowsViewModel _collapsibleRowsVM;
  final JourneyPositionViewModel _positionVM;
  final DetailModalViewModel _detailModalVM;
  final DecisiveGradientViewModel _decisiveGradientVM;
  final JourneyNavigationViewModel _navigationVM;
  final UserSettings _userSettings;

  StreamSubscription? _streamSubscription;

  final _rxModel = BehaviorSubject<JourneyTableModel>.seeded(TableLoading());

  Stream<JourneyTableModel> get model => _rxModel.stream;

  JourneyTableModel get modelValue => _rxModel.value;

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _emitLoading();
    _init();
  }

  void _init() {
    _streamSubscription?.cancel();
    _streamSubscription =
        CombineLatestStream.combine7(
          journeyViewModel.journey,
          _settingsVM.model,
          _collapsibleRowsVM.collapsedRows,
          _positionVM.model,
          _detailModalVM.openModalType,
          _decisiveGradientVM.showDecisiveGradient,
          _navigationVM.model,
          (a, b, c, d, e, f, g) => (a, b, c, d, e, f, g),
        ).listen(
          (data) => _handleDataChanged(
            journey: data.$1,
            settings: data.$2,
            collapsibleRows: data.$3,
            position: data.$4,
            detailModalType: data.$5,
            showDecisiveGradient: data.$6,
            navigationModel: data.$7,
          ),
        );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _rxModel.close();
    super.dispose();
  }

  void _handleDataChanged({
    required JourneySettings settings,
    required Map<int, CollapsedState> collapsibleRows,
    required JourneyPositionModel position,
    required bool showDecisiveGradient,
    JourneyNavigationModel? navigationModel,
    DetailModalType? detailModalType,
    Journey? journey,
  }) {
    if (journey == null) {
      _emitLoading();
      return;
    }
    final rowData = journey.data
        .whereNot((it) => _isCurvePointWithoutSpeed(it, settings))
        .hideJourneyPointsThatShouldNotBeDisplayed()
        .groupBaliseAndLevelCrossings(settings.expandedGroups, journey.metadata)
        .hideCommunicationNetworkChangesWithSameTypeAsPreviousOrIsServicePoint()
        .hideRepeatedLineFootNotes(position.currentPosition)
        .hideFootNotesForNotSelectedTrainSeries(settings.currentBrakeSeries?.trainSeries)
        .combineFootNoteAndOperationalIndication()
        .addTrainDriverTurnoverRows(navigationModel?.trainIdentification)
        .hideSignals(stationSignals: !_userSettings.showStationSignals)
        .sorted((a1, a2) => a1.compareTo(a2));

    _emitLoaded(
      TableLoaded(
        journeyTableRowData: rowData,
        journeyMetadata: journey.metadata,
        journeySettings: settings,
        collapsedRows: collapsibleRows,
        journeyPosition: position,
        showDecisiveGradient: showDecisiveGradient,
        detailModalType: detailModalType,
      ),
    );
  }

  bool _isCurvePointWithoutSpeed(BaseData data, JourneySettings settings) {
    final brakeSeries = settings.currentBrakeSeries;

    return data is CurvePoint &&
        data.localSpeeds?.speedFor(brakeSeries?.trainSeries, brakeSeries: brakeSeries?.brakeSeries) == null;
  }

  void _emitLoading() {
    _log.fine('Emitting TableLoading.');
    _rxModel.add(TableLoading());
  }

  void _emitLoaded(TableLoaded loadedModel) {
    _log.fine('Emitting TableLoaded.');
    _rxModel.add(loadedModel);
  }
}

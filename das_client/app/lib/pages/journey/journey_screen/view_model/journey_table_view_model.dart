import 'dart:async';

import 'package:app/extension/base_data_extension.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/chevron_position_model.dart';
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
import 'package:core_data/component.dart';
import 'package:logging/logging.dart';
import 'package:ru_indications/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyTableViewModel');

class JourneyTableViewModel extends JourneyAwareViewModel {
  JourneyTableViewModel({
    required super.journeyViewModel,
    required this._settingsVM,
    required this._collapsibleRowsVM,
    required this._positionVM,
    required this._detailModalVM,
    required this._decisiveGradientVM,
    required this._navigationVM,
    required this._userSettings,
    required this._ruIndicationsRepository,
  }) {
    _init();
  }

  final JourneySettingsViewModel _settingsVM;
  final CollapsibleRowsViewModel _collapsibleRowsVM;
  final JourneyPositionViewModel _positionVM;
  final DetailModalViewModel _detailModalVM;
  final DecisiveGradientViewModel _decisiveGradientVM;
  final JourneyNavigationViewModel _navigationVM;
  final UserSettings _userSettings;
  final RuIndicationsRepository _ruIndicationsRepository;

  StreamSubscription? _streamSubscription;

  final _rxRuIndications = BehaviorSubject<List<RuIndication>>.seeded([]);
  final _rxModel = BehaviorSubject<JourneyTableModel>.seeded(TableLoading());

  Stream<JourneyTableModel> get model => _rxModel.stream;

  JourneyTableModel get modelValue => _rxModel.value;

  JourneyPoint? _journeyStart;
  JourneyPoint? _journeyEnd;

  JourneyPoint? get journeyStart => _journeyStart;

  JourneyPoint? get journeyEnd => _journeyEnd;

  @override
  void onJourneyChanged(Journey? journey) {
    _emitLoading();
    _init();
  }

  void _init() {
    _initRxModel();
    _initRxRuIndications();
  }

  Future<void> _initRxRuIndications() async {
    final trainIdentification = lastJourney?.metadata.trainIdentification;
    if (trainIdentification != null) {
      final servicePoints = lastJourney!.data.whereType<ServicePoint>();
      final locationReferences = {for (final it in servicePoints) it.locationCode: it.order};
      final ruIndications = await _ruIndicationsRepository.fetchRuIndications(
        company: trainIdentification.ru.companyCode,
        trainNumber: trainIdentification.trainNumber,
        startDate: trainIdentification.operatingDay ?? DateTime.now(), // TODO: What to do when operatingDay not given?
        locationReferences: locationReferences,
      );
      _rxRuIndications.add(ruIndications);
    }
  }

  void _initRxModel() {
    _streamSubscription?.cancel();
    _streamSubscription =
        CombineLatestStream.combine9(
          journeyViewModel.journey,
          _settingsVM.model,
          _collapsibleRowsVM.collapsedRows,
          _positionVM.model,
          _detailModalVM.openModalType,
          _decisiveGradientVM.showDecisiveGradient,
          _navigationVM.model,
          _userSettings.model,
          _rxRuIndications,
          (a, b, c, d, e, f, g, h, i) => (a, b, c, d, e, f, g, h, i),
        ).listen(
          (data) => _handleDataChanged(
            journey: data.$1,
            settings: data.$2,
            collapsibleRows: data.$3,
            position: data.$4,
            detailModalType: data.$5,
            showDecisiveGradient: data.$6,
            navigationModel: data.$7,
            ruIndications: data.$9,
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
    required List<RuIndication> ruIndications,
    JourneyNavigationModel? navigationModel,
    DetailModalType? detailModalType,
    Journey? journey,
  }) {
    if (journey == null) {
      _emitLoading();
      return;
    }
    final rowData = journey.data
      ..addAll(ruIndications)
      ..whereNot((it) => _isCurvePointWithoutSpeed(it, settings))
          .hideJourneyPointsThatShouldNotBeDisplayed()
          .groupBaliseAndLevelCrossings(settings.expandedGroups, journey.metadata)
          .hideCommunicationNetworkChangesWithSameTypeAsPreviousOrIsServicePoint()
          .hideRepeatedLineFootNotes(position.currentPosition)
          .hideFootNotesForNotSelectedTrainSeries(settings.currentBrakeSeries?.trainSeries)
          .combineFootNoteAndIndications()
          .addTrainDriverTurnoverRows(navigationModel?.trainIdentification)
          .hideSignals(
            stationSignals: !_userSettings.showStationSignals,
            conventionalSpeedSignals: !_userSettings.showEctsConventionalSpeedSignals,
            extendedSpeedSignals: !_userSettings.showEctsExtendedSpeedSignals,
            nonStandardTrackEquipmentSegments: journey.metadata.nonStandardTrackEquipmentSegments,
          )
          .sorted((a1, a2) => a1.compareTo(a2));

    final journeyPoints = rowData.whereType<JourneyPoint>();
    final chevronPosition = _calculateChevronPosition(visibleJourneyPoints: journeyPoints, position: position);
    _journeyStart = journeyPoints.firstOrNull;
    _journeyEnd = journeyPoints.lastOrNull;

    _emitLoaded(
      TableLoaded(
        journeyTableRowData: rowData,
        journeyMetadata: journey.metadata,
        journeySettings: settings,
        collapsedRows: collapsibleRows,
        journeyPosition: position,
        chevronPosition: chevronPosition,
        showDecisiveGradient: showDecisiveGradient,
        detailModalType: detailModalType,
      ),
    );
  }

  ChevronPositionModel _calculateChevronPosition({
    required Iterable<JourneyPoint> visibleJourneyPoints,
    required JourneyPositionModel position,
  }) {
    final lastVisiblePosition = _positionOrLastVisibleBefore(visibleJourneyPoints, position.lastPosition);
    final currentVisiblePosition = _positionOrLastVisibleBefore(
      visibleJourneyPoints,
      position.currentPosition,
    );

    if (lastVisiblePosition != position.lastPosition) {
      _log.fine(
        'Last position ${position.lastPosition} is not visible, using $lastVisiblePosition as last position for chevron animation.',
      );
    }

    if (currentVisiblePosition != position.currentPosition) {
      _log.fine(
        'Current position ${position.currentPosition} is not visible, using $currentVisiblePosition as current position for chevron animation.',
      );
    }

    return ChevronPositionModel(
      currentPosition: currentVisiblePosition,
      lastPosition: lastVisiblePosition,
    );
  }

  JourneyPoint? _positionOrLastVisibleBefore(Iterable<JourneyPoint> visibleJourneyPoints, JourneyPoint? position) {
    if (position == null) return null;
    if (visibleJourneyPoints.contains(position)) return position;

    return visibleJourneyPoints.lastWhere((it) => it.order <= position.order);
  }

  bool _isCurvePointWithoutSpeed(BaseData data, JourneySettings settings) {
    final brakeSeries = settings.currentBrakeSeries;

    return data is CurvePoint &&
        data.localSpeeds?.speedFor(brakeSeries?.trainSeries, brakeSeries: brakeSeries?.brakeSeries) == null;
  }

  void _emitLoading() {
    _journeyStart = null;
    _journeyEnd = null;
    _log.fine('Emitting TableLoading.');
    _rxModel.add(TableLoading());
  }

  void _emitLoaded(TableLoaded loadedModel) {
    _log.fine('Emitting TableLoaded.');
    _rxModel.add(loadedModel);
  }
}

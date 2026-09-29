import 'dart:async';

import 'package:app/extension/base_data_extension.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/chevron_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_table_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/personal_note_annotation.dart';
import 'package:app/pages/journey/journey_screen/view_model/personal_notes_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/combined_foot_note_and_text_annotations.dart';
import 'package:app/pages/journey/view_model/decisive_gradient_view_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/model/journey_navigation_model.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:app/provider/local_key_value_store.dart';
import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyTableViewModel');

class JourneyTableViewModel({
  required super.journeyViewModel,
  required final JourneySettingsViewModel _settingsVM,
  required final CollapsibleRowsViewModel _collapsibleRowsVM,
  required final JourneyPositionViewModel _positionVM,
  required final DetailModalViewModel _detailModalVM,
  required final DecisiveGradientViewModel _decisiveGradientVM,
  required final JourneyNavigationViewModel _navigationVM,
  required final PersonalNotesViewModel _personalNotesVM,
  required final LocalKeyValueStore _userSettings,
  required final AcknowledgedModificationRepository _acknowledgedModificationRepository,
}) extends JourneyAwareViewModel {
  this {
    _init();
  }

  StreamSubscription? _streamSubscription;

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
  }

  void _initRxModel() {
    _streamSubscription?.cancel();
    _streamSubscription =
        CombineLatestStream.list([
          journeyViewModel.journey,
          _settingsVM.model,
          _collapsibleRowsVM.collapsedRows,
          _positionVM.model,
          _detailModalVM.openModalType,
          _decisiveGradientVM.showDecisiveGradient,
          _navigationVM.model,
          _userSettings.model,
          _personalNotesVM.personalNoteAnnotations,
          _acknowledgedModificationRepository.model,
        ]).listen(
          (data) => _handleDataChanged(
            journey: data[0] as Journey?,
            settings: data[1] as JourneySettings,
            collapsibleRows: data[2] as Map<int, CollapsedState>,
            position: data[3] as JourneyPositionModel,
            detailModalType: data[4] as DetailModalType?,
            showDecisiveGradient: data[5] as bool,
            navigationModel: data[6] as JourneyNavigationModel?,
            acknowledgedModifications: data[8] as Set<Modification>,
            personalNoteAnnotations: data[9] as List<PersonalNoteAnnotation>,
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
    required Set<Modification> acknowledgedModifications,
    required List<PersonalNoteAnnotation> personalNoteAnnotations,
    JourneyNavigationModel? navigationModel,
    DetailModalType? detailModalType,
    Journey? journey,
  }) {
    if (journey == null) {
      _emitLoading();
      return;
    }

    final journeyData = [...journey.data, ...personalNoteAnnotations];

    final rowData = journeyData
        .whereNot((it) => _isCurvePointWithoutSpeed(it, settings))
        .removeIrrelevantServicePoints(journey.metadata.calculatedSpeeds)
        .hideJourneyPointsThatShouldNotBeDisplayed()
        .hideAcknowledgedDeletedRows(acknowledgedModifications, settings)
        .groupBaliseAndLevelCrossings(settings.expandedGroups, journey.metadata)
        .hideCommunicationNetworkChangesWithSameTypeAsPreviousOrIsServicePoint()
        .hideRepeatedLineFootNotes(position.currentPosition)
        .hideFootNotesForNotSelectedTrainSeries(settings.currentBrakeSeries?.trainSeries)
        .combineFootNoteAndTextAnnotations()
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
        acknowledgedModifications: acknowledgedModifications,
      ),
    );
  }

  ChevronPositionModel _calculateChevronPosition({
    required Iterable<JourneyPoint> visibleJourneyPoints,
    required JourneyPositionModel position,
  }) {
    final lastVisiblePosition = _positionOrLastVisibleBefore(visibleJourneyPoints, position.lastPosition);
    if (lastVisiblePosition != position.lastPosition) {
      _log.fine(
        'Last position ${position.lastPosition} is not visible, using $lastVisiblePosition as last position for chevron animation.',
      );
    }

    final currentVisiblePosition = _positionOrLastVisibleBefore(visibleJourneyPoints, position.currentPosition);
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

    return visibleJourneyPoints.lastWhereOrNull((it) => it.order <= position.order);
  }

  bool _isCurvePointWithoutSpeed(BaseData data, JourneySettings settings) {
    final brakeSeries = settings.currentBrakeSeries;

    return data is CurvePoint &&
        data.localSpeeds?.speedFor(
              brakeSeries?.trainSeries,
              brakedWeightPercentage: brakeSeries?.brakedWeightPercentage,
            ) ==
            null;
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

  void acknowledgeModification(Modification modification) {
    _log.info('Acknowledging modification: $modification');
    _acknowledgedModificationRepository.insert(modification);
  }

  void undoModificationAcknowledgement(Modification modification) {
    _log.info('Undoing acknowledgement of modification: $modification');
    _acknowledgedModificationRepository.delete(modification);
  }
}

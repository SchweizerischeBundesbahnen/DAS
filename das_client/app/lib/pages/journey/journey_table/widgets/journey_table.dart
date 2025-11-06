import 'dart:io';

import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_table/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_table/journey_overview.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/break_series_selection.dart';
import 'package:app/pages/journey/journey_table/widgets/chevron_animation_wrapper.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/table/additional_speed_restriction_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/arrival_departure_time/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/table/balise_level_crossing_group_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/balise_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/cab_signaling_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/journey_table/widgets/table/column_definition.dart';
import 'package:app/pages/journey/journey_table/widgets/table/combined_foot_note_operational_indication_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/communication_network_change_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/config/bracket_station_render_data.dart';
import 'package:app/pages/journey/journey_table/widgets/table/config/chevron_animation_data.dart';
import 'package:app/pages/journey/journey_table/widgets/table/config/journey_config.dart';
import 'package:app/pages/journey/journey_table/widgets/table/config/journey_settings.dart';
import 'package:app/pages/journey/journey_table/widgets/table/config/track_equipment_render_data.dart';
import 'package:app/pages/journey/journey_table/widgets/table/connection_track_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/curve_point_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/foot_note_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/level_crossing_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/loading_table.dart';
import 'package:app/pages/journey/journey_table/widgets/table/protection_section_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/service_point_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/shunting_movement_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/signal_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/speed_change_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/tram_area_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/uncoded_operational_indication_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/whistle_row.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/user_settings.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:app/widgets/table/das_table_column.dart';
import 'package:app/widgets/table/das_table_row.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class JourneyTable extends StatelessWidget {
  const JourneyTable({super.key});

  static const Key loadedJourneyTableKey = Key('loadedJourneyTable');
  static const Key breakingSeriesHeaderKey = Key('breakingSeriesHeader');

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JourneyTableViewModel>();
    final journeyPositionViewModel = context.read<JourneyPositionViewModel>();

    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream.list([
        viewModel.journey,
        viewModel.settings,
        viewModel.showDecisiveGradient,
        journeyPositionViewModel.model,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?[0] == null) {
          return JourneyLoadingTable(columns: _columns(context, null, null, null));
        }

        final journey = snapshot.data![0] as Journey;
        final settings = snapshot.data![1] as JourneySettings;
        final journeyPosition = snapshot.data![3] as JourneyPositionModel;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.automaticAdvancementController.handleJourneyUpdate(
            currentPosition: journeyPosition.currentPosition,
            routeStart: journey.metadata.journeyStart,
            isAdvancementEnabledByUser: settings.isAutoAdvancementEnabled,
            firstServicePoint: journey.data.whereType<ServicePoint>().firstOrNull,
          );
        });

        final servicePointModalViewModel = context.read<ServicePointModalViewModel>();
        servicePointModalViewModel.updateMetadata(journey.metadata);
        servicePointModalViewModel.updateSettings(settings);

        return KeyedSubtree(
          key: loadedJourneyTableKey,
          child: Listener(
            onPointerDown: (_) => viewModel.automaticAdvancementController.resetScrollTimer(),
            onPointerUp: (_) => viewModel.automaticAdvancementController.resetScrollTimer(),
            child: _body(context, journey, settings, journeyPosition),
          ),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    Journey journey,
    JourneySettings settings,
    JourneyPositionModel journeyPosition,
  ) {
    final collapsibleRowsViewModel = context.read<CollapsibleRowsViewModel>();
    final journeyPositionViewModel = context.read<JourneyPositionViewModel>();
    return StreamBuilder(
      stream: CombineLatestStream.combine2(
        collapsibleRowsViewModel.collapsedRows,
        journeyPositionViewModel.model,
        (a, b) => (a, b),
      ),
      initialData: (collapsibleRowsViewModel.collapsedRowsValue, journeyPositionViewModel.modelValue),
      builder: (context, snapshot) {
        final collapsedRows = snapshot.data?.$1 ?? {};
        final journeyPosition = snapshot.data!.$2;
        final tableRows = _rows(context, journey, settings, collapsedRows, journeyPosition);
        context.read<JourneyTableViewModel>().automaticAdvancementController.updateRenderedRows(tableRows);

        final marginAdjustment = Platform.isIOS
            ? tableRows.lastWhereOrNull((it) => it.stickyLevel == StickyLevel.first)?.height ?? CellRowBuilder.rowHeight
            : 0.0;

        final detailModalViewModel = context.read<DetailModalViewModel>();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: JourneyOverview.horizontalPadding),
          child: StreamBuilder(
            stream: detailModalViewModel.openModalType,
            builder: (context, snapshot) {
              final openModalType = snapshot.data;
              final advancementController = context.read<JourneyTableViewModel>().automaticAdvancementController;
              return ChevronAnimationWrapper(
                journeyPosition: journeyPosition,
                child: DASTable(
                  key: advancementController.tableKey,
                  scrollController: advancementController.scrollController,
                  columns: _columns(context, journey.metadata, settings, openModalType),
                  rows: tableRows.map((it) => it.build(context)).toList(),
                  bottomMarginAdjustment: marginAdjustment,
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<DASTableRowBuilder> _rows(
    BuildContext context,
    Journey journey,
    JourneySettings settings,
    Map<int, CollapsedState> collapsedRows,
    JourneyPositionModel journeyPosition,
  ) {
    final currentBreakSeries = settings.resolvedBreakSeries(journey.metadata);

    final rows = journey.data
        .whereNot((it) => _isCurvePointWithoutSpeed(it, journey, settings))
        .groupBaliseAndLevelCrossings(settings.expandedGroups, journey.metadata)
        .hideRepeatedLineFootNotes(journeyPosition.currentPosition)
        .hideFootNotesForNotSelectedTrainSeries(currentBreakSeries?.trainSeries)
        .combineFootNoteAndOperationalIndication()
        .sorted((a1, a2) => a1.compareTo(a2));

    final groupedRows = rows
        .whereType<BaliseLevelCrossingGroup>()
        .map((it) => it.groupedElements)
        .expand((it) => it)
        .toList();

    final journeyPoints = rows.whereType<JourneyPoint>().toList();

    return List.generate(rows.length, (index) {
      final rowData = rows[index];

      final journeyConfig = JourneyConfig(
        settings: settings,
        trackEquipmentRenderData: TrackEquipmentRenderData.from(
          rows,
          journey.metadata,
          index,
          currentBreakSeries,
        ),
        bracketStationRenderData: BracketStationRenderData.from(rowData, journey.metadata),
        chevronAnimationData: ChevronAnimationData.from(
          journeyPoints,
          journeyPosition,
          journey.metadata,
          rowData,
          currentBreakSeries,
          settings.expandedGroups,
        ),
      );

      var hasPreviousAnnotation = false;
      if (index > 0) {
        final previous = rows[index - 1];
        hasPreviousAnnotation = previous is JourneyAnnotation;
      }

      switch (rowData.type) {
        case Datatype.servicePoint:
          return ServicePointRow(
            metadata: journey.metadata,
            data: rowData as ServicePoint,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            context: context,
            rowIndex: index,
          );
        case Datatype.protectionSection:
          return ProtectionSectionRow(
            metadata: journey.metadata,
            data: rowData as ProtectionSection,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case Datatype.curvePoint:
          return CurvePointRow(
            metadata: journey.metadata,
            data: rowData as CurvePoint,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case Datatype.signal:
          return SignalRow(
            metadata: journey.metadata,
            data: rowData as Signal,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case Datatype.additionalSpeedRestriction:
          return AdditionalSpeedRestrictionRow(
            metadata: journey.metadata,
            data: rowData as AdditionalSpeedRestrictionData,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            onTap: () => _onAdditionalSpeedRestrictionTab(context, rowData),
            rowIndex: index,
          );
        case Datatype.connectionTrack:
          return ConnectionTrackRow(
            metadata: journey.metadata,
            data: rowData as ConnectionTrack,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case Datatype.speedChange:
          return SpeedChangeRow(
            metadata: journey.metadata,
            data: rowData as SpeedChange,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case Datatype.cabSignaling:
          return CABSignalingRow(
            metadata: journey.metadata,
            data: rowData as CABSignaling,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case Datatype.balise:
          return BaliseRow(
            metadata: journey.metadata,
            data: rowData as Balise,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            isGrouped: groupedRows.contains(rowData),
            rowIndex: index,
          );
        case Datatype.whistle:
          return WhistleRow(
            metadata: journey.metadata,
            data: rowData as Whistle,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case Datatype.levelCrossing:
          return LevelCrossingRow(
            metadata: journey.metadata,
            data: rowData as LevelCrossing,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            isGrouped: groupedRows.contains(rowData),
            rowIndex: index,
          );
        case Datatype.tramArea:
          return TramAreaRow(
            metadata: journey.metadata,
            data: rowData as TramArea,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case Datatype.baliseLevelCrossingGroup:
          return BaliseLevelCrossingGroupRow(
            metadata: journey.metadata,
            data: rowData as BaliseLevelCrossingGroup,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            onTap: () => _onBaliseLevelCrossingGroupTap(context, rowData, settings),
            rowIndex: index,
            context: context,
            isExpanded: settings.expandedGroups.contains(rowData.order),
          );
        case Datatype.opFootNote || Datatype.lineFootNote || Datatype.trackFootNote:
          return FootNoteRow(
            metadata: journey.metadata,
            data: rowData as BaseFootNote,
            config: journeyConfig,
            isExpanded: collapsedRows.stateOf(rowData) != CollapsedState.collapsed,
            addTopMargin: !hasPreviousAnnotation,
            rowIndex: index,
          );
        case Datatype.uncodedOperationalIndication:
          return UncodedOperationalIndicationRow(
            metadata: journey.metadata,
            data: rowData as UncodedOperationalIndication,
            config: journeyConfig,
            collapsedState: collapsedRows.stateOf(rowData),
            addTopMargin: !hasPreviousAnnotation,
            rowIndex: index,
          );
        case Datatype.combinedFootNoteOperationalIndication:
          return CombinedFootNoteOperationalIndicationRow(
            rowIndex: index,
            metadata: journey.metadata,
            data: rowData as CombinedFootNoteOperationalIndication,
            footNoteState: collapsedRows.stateOf(rowData.footNote),
            operationIndicationState: collapsedRows.stateOf(rowData.operationalIndication),
          );
        case Datatype.communicationNetworkChannel:
          return CommunicationNetworkChangeRow(
            metadata: journey.metadata,
            data: rowData as CommunicationNetworkChange,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
            context: context,
          );
        case Datatype.shuntingMovement:
          return ShuntingMovementRow(
            metadata: journey.metadata,
            data: rowData as ShuntingMovement,
            rowIndex: index,
          );
      }
    });
  }

  List<DASTableColumn> _columns(
    BuildContext context,
    Metadata? metadata,
    JourneySettings? settings,
    DetailModalType? openModalType,
  ) {
    final currentBreakSeries = settings?.resolvedBreakSeries(metadata);

    final journeyViewModel = context.read<JourneyTableViewModel>();
    final timeViewModel = context.read<ArrivalDepartureTimeViewModel>();
    final userSettings = DI.get<UserSettings>();

    return [
      if (openModalType == null || openModalType == DetailModalType.additionalSpeedRestriction) ...[
        if (userSettings.showDecisiveGradient ||
            (!userSettings.showDecisiveGradient && !journeyViewModel.showDecisiveGradientValue))
          DASTableColumn(
            id: ColumnDefinition.kilometre.index,
            child: Text(context.l10n.p_train_journey_table_kilometre_label),
            width: 64.0,
            onTap: !userSettings.showDecisiveGradient ? () => journeyViewModel.toggleKmDecisiveGradient() : null,
          ),
        if (userSettings.showDecisiveGradient || journeyViewModel.showDecisiveGradientValue) ...[
          DASTableColumn(
            id: ColumnDefinition.gradientDownhill.index,
            child: Text('-'),
            width: 40.0,
            onTap: !userSettings.showDecisiveGradient ? () => journeyViewModel.toggleKmDecisiveGradient() : null,
          ),
          DASTableColumn(
            id: ColumnDefinition.gradientUphill.index,
            child: Text('+'),
            width: 40.0,
            onTap: !userSettings.showDecisiveGradient ? () => journeyViewModel.toggleKmDecisiveGradient() : null,
          ),
        ],
      ],
      if (openModalType == null || openModalType != DetailModalType.additionalSpeedRestriction)
        DASTableColumn(
          id: ColumnDefinition.time.index,
          child: StreamBuilder(
            stream: timeViewModel.showOperationalTime,
            builder: (context, showCalcTimeSnap) => Text(
              showCalcTimeSnap.data ?? false
                  ? context.l10n.p_train_journey_table_time_label_new
                  : context.l10n.p_train_journey_table_time_label_planned,
            ),
          ),
          width: 100.0,
          onTap: () {
            final viewModel = context.read<ArrivalDepartureTimeViewModel>();
            viewModel.toggleOperationalTime();
          },
        ),
      DASTableColumn(id: ColumnDefinition.route.index, width: 48.0), // route column
      DASTableColumn(id: ColumnDefinition.trackEquipment.index, width: 20.0), // track equipment column
      DASTableColumn(id: ColumnDefinition.icons1.index, width: 64.0), // icons column
      DASTableColumn(id: ColumnDefinition.bracketStation.index, width: 0.0), // bracket station column
      DASTableColumn(
        id: ColumnDefinition.informationCell.index,
        child: Text(context.l10n.p_train_journey_table_journey_information_label),
        expanded: true,
        alignment: Alignment.centerLeft,
      ),
      DASTableColumn(id: ColumnDefinition.icons2.index, width: 68.0), // icons column
      DASTableColumn(id: ColumnDefinition.icons3.index, width: 48.0), // icons column
      DASTableColumn(
        id: ColumnDefinition.localSpeed.index,
        child: Text(context.l10n.p_train_journey_table_graduated_speed_label),
        width: 100.0,
        border: BorderDirectional(
          bottom: BorderSide(color: ThemeUtil.getDASTableBorderColor(context), width: 1.0),
          end: BorderSide(color: ThemeUtil.getDASTableBorderColor(context), width: 2.0),
        ),
      ),
      DASTableColumn(
        id: ColumnDefinition.brakedWeightSpeed.index,
        child: Text(currentBreakSeries?.name ?? '??'),
        width: 62.0,
        onTap: () => _onBreakSeriesTap(context, metadata, settings),
        headerKey: breakingSeriesHeaderKey,
      ),
      DASTableColumn(
        id: ColumnDefinition.advisedSpeed.index,
        child: Text(context.l10n.p_train_journey_table_advised_speed_label),
        width: 62.0,
      ),
    ];
  }

  void _onBaliseLevelCrossingGroupTap(
    BuildContext context,
    BaliseLevelCrossingGroup group,
    JourneySettings settings,
  ) {
    final newList = List<int>.from(settings.expandedGroups);
    if (settings.expandedGroups.contains(group.order)) {
      newList.remove(group.order);
    } else {
      newList.add(group.order);
    }

    context.read<JourneyTableViewModel>().updateExpandedGroups(newList);
  }

  Future<void> _onBreakSeriesTap(BuildContext context, Metadata? metadata, JourneySettings? settings) async {
    final viewModel = context.read<JourneyTableViewModel>();

    final selectedBreakSeries = await showSBBModalSheet<BreakSeries>(
      context: context,
      title: context.l10n.p_train_journey_break_series,
      constraints: BoxConstraints(),
      child: BreakSeriesSelection(
        availableBreakSeries: metadata?.availableBreakSeries ?? {},
        selectedBreakSeries: settings?.resolvedBreakSeries(metadata),
      ),
    );

    if (selectedBreakSeries != null) viewModel.updateBreakSeries(selectedBreakSeries);
  }

  bool _isCurvePointWithoutSpeed(BaseData data, Journey journey, JourneySettings settings) {
    final breakSeries = settings.resolvedBreakSeries(journey.metadata);

    return data is CurvePoint &&
        data.localSpeeds?.speedFor(breakSeries?.trainSeries, breakSeries: breakSeries?.breakSeries) == null;
  }

  void _onAdditionalSpeedRestrictionTab(BuildContext context, AdditionalSpeedRestrictionData data) {
    final viewModel = context.read<AdditionalSpeedRestrictionModalViewModel>();
    viewModel.open(context, data.restrictions);
  }
}

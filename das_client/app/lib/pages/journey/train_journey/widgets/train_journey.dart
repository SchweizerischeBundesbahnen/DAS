import 'dart:io';

import 'package:app/bloc/train_journey_cubit.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/break_series_selection.dart';
import 'package:app/pages/journey/train_journey/widgets/chevron_animation_wrapper.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/additional_speed_restriction_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/arrival_departure_time/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/balise_level_crossing_group_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/balise_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cab_signaling_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/table/column_definition.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/bracket_station_render_data.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/chevron_animation_data.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/track_equipment_render_data.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_config.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/pages/journey/train_journey/widgets/table/connection_track_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/curve_point_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/level_crossing_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/line_foot_note_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/op_foot_note_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/protection_section_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/signal_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/speed_change_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/track_foot_note_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/tram_area_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/whistle_row.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:app/widgets/table/das_table_column.dart';
import 'package:app/widgets/table/das_table_row.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class TrainJourney extends StatelessWidget {
  const TrainJourney({super.key});

  static const Key breakingSeriesHeaderKey = Key('breakingSeriesHeader');

  @override
  Widget build(BuildContext context) {
    final bloc = context.trainJourneyCubit;

    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream.list([bloc.journeyStream, bloc.settingsStream]),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?[0] == null) {
          return Container();
        }

        final journey = snapshot.data![0] as Journey;
        final settings = snapshot.data![1] as TrainJourneySettings;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          bloc.automaticAdvancementController.handleJourneyUpdate(
            currentPosition: journey.metadata.currentPosition,
            routeStart: journey.metadata.routeStart,
            isAdvancementEnabledByUser: settings.isAutoAdvancementEnabled,
          );
        });

        final detailModelSheetViewModel = context.read<DetailModalSheetViewModel>();
        detailModelSheetViewModel.updateMetadata(journey.metadata);
        detailModelSheetViewModel.updateSettings(settings);

        return Listener(
          onPointerDown: (_) => bloc.automaticAdvancementController.resetScrollTimer(),
          onPointerUp: (_) => bloc.automaticAdvancementController.resetScrollTimer(),
          child: _body(context, journey, settings),
        );
      },
    );
  }

  Widget _body(BuildContext context, Journey journey, TrainJourneySettings settings) {
    final tableRows = _rows(context, journey, settings);
    context.trainJourneyCubit.automaticAdvancementController.updateRenderedRows(tableRows);

    final marginAdjustment = Platform.isIOS
        ? tableRows.lastWhereOrNull((it) => it.stickyLevel == StickyLevel.first)?.height ?? CellRowBuilder.rowHeight
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing * 0.5),
      child: StreamBuilder<bool>(
        stream: context.read<DetailModalSheetViewModel>().isModalSheetOpen,
        builder: (context, snapshot) {
          final isDetailModelSheetOpen = snapshot.data ?? false;
          return ChevronAnimationWrapper(
            journey: journey,
            child: DASTable(
              key: context.trainJourneyCubit.automaticAdvancementController.tableKey,
              scrollController: context.trainJourneyCubit.automaticAdvancementController.scrollController,
              columns: _columns(context, journey.metadata, settings, isDetailModelSheetOpen),
              rows: tableRows.map((it) => it.build(context)).toList(),
              bottomMarginAdjustment: marginAdjustment,
            ),
          );
        },
      ),
    );
  }

  List<DASTableRowBuilder> _rows(BuildContext context, Journey journey, TrainJourneySettings settings) {
    final currentBreakSeries = settings.resolvedBreakSeries(journey.metadata);

    final rows = journey.data
        .whereNot((it) => _isCurvePointWithoutSpeed(it, journey, settings))
        .groupBaliseAndLeveLCrossings(settings.expandedGroups)
        .hideRepeatedLineFootNotes(journey.metadata.currentPosition)
        .hideFootNotesForNotSelectedTrainSeries(currentBreakSeries?.trainSeries)
        .toList();

    final groupedRows =
        rows.whereType<BaliseLevelCrossingGroup>().map((it) => it.groupedElements).expand((it) => it).toList();

    return List.generate(rows.length, (index) {
      final rowData = rows[index];

      final trainJourneyConfig = TrainJourneyConfig(
        settings: settings,
        trackEquipmentRenderData: TrackEquipmentRenderData.from(rows, journey.metadata, index),
        bracketStationRenderData: BracketStationRenderData.from(rowData, journey.metadata),
        chevronAnimationData: ChevronAnimationData.from(rows, journey, rowData),
      );
      switch (rowData.type) {
        case Datatype.servicePoint:
          return ServicePointRow(
            metadata: journey.metadata,
            data: rowData as ServicePoint,
            config: trainJourneyConfig,
            context: context,
          );
        case Datatype.protectionSection:
          return ProtectionSectionRow(
            metadata: journey.metadata,
            data: rowData as ProtectionSection,
            config: trainJourneyConfig,
          );
        case Datatype.curvePoint:
          return CurvePointRow(
            metadata: journey.metadata,
            data: rowData as CurvePoint,
            config: trainJourneyConfig,
          );
        case Datatype.signal:
          return SignalRow(
            metadata: journey.metadata,
            data: rowData as Signal,
            config: trainJourneyConfig,
          );
        case Datatype.additionalSpeedRestriction:
          return AdditionalSpeedRestrictionRow(
            metadata: journey.metadata,
            data: rowData as AdditionalSpeedRestrictionData,
            config: trainJourneyConfig,
          );
        case Datatype.connectionTrack:
          return ConnectionTrackRow(
            metadata: journey.metadata,
            data: rowData as ConnectionTrack,
            config: trainJourneyConfig,
          );
        case Datatype.speedChange:
          return SpeedChangeRow(
            metadata: journey.metadata,
            data: rowData as SpeedChange,
            config: trainJourneyConfig,
          );
        case Datatype.cabSignaling:
          return CABSignalingRow(
            metadata: journey.metadata,
            data: rowData as CABSignaling,
            config: trainJourneyConfig,
          );
        case Datatype.balise:
          return BaliseRow(
            metadata: journey.metadata,
            data: rowData as Balise,
            config: trainJourneyConfig,
            isGrouped: groupedRows.contains(rowData),
          );
        case Datatype.whistle:
          return WhistleRow(
            metadata: journey.metadata,
            data: rowData as Whistle,
            config: trainJourneyConfig,
          );
        case Datatype.levelCrossing:
          return LevelCrossingRow(
            metadata: journey.metadata,
            data: rowData as LevelCrossing,
            config: trainJourneyConfig,
            isGrouped: groupedRows.contains(rowData),
          );
        case Datatype.tramArea:
          return TramAreaRow(
            metadata: journey.metadata,
            data: rowData as TramArea,
            config: trainJourneyConfig,
          );
        case Datatype.baliseLevelCrossingGroup:
          return BaliseLevelCrossingGroupRow(
            metadata: journey.metadata,
            data: rowData as BaliseLevelCrossingGroup,
            config: trainJourneyConfig,
            onTap: () => _onBaliseLevelCrossingGroupTap(context, rowData, settings),
          );
        case Datatype.opFootNote:
          return OpFootNoteRow(
            metadata: journey.metadata,
            data: rowData as OpFootNote,
            config: trainJourneyConfig,
            isExpanded: !settings.collapsedFootNotes.contains(rowData.identifier),
            accordionToggleCallback: () => _onFootNoteExpanded(context, rowData, settings),
          );
        case Datatype.lineFootNote:
          return LineFootNoteRow(
            metadata: journey.metadata,
            data: rowData as LineFootNote,
            config: trainJourneyConfig,
            isExpanded: !settings.collapsedFootNotes.contains(rowData.identifier),
            accordionToggleCallback: () => _onFootNoteExpanded(context, rowData, settings),
          );
        case Datatype.trackFootNote:
          return TrackFootNoteRow(
            metadata: journey.metadata,
            data: rowData as TrackFootNote,
            config: trainJourneyConfig,
            isExpanded: !settings.collapsedFootNotes.contains(rowData.identifier),
            accordionToggleCallback: () => _onFootNoteExpanded(context, rowData, settings),
          );
      }
    });
  }

  List<DASTableColumn> _columns(
    BuildContext context,
    Metadata metadata,
    TrainJourneySettings settings,
    bool isDetailModelSheetOpen,
  ) {
    final currentBreakSeries = settings.resolvedBreakSeries(metadata);
    final speedLabel =
        currentBreakSeries != null ? '${currentBreakSeries.trainSeries.name}${currentBreakSeries.breakSeries}' : '??';

    final timeViewModel = context.read<ArrivalDepartureTimeViewModel>();

    return [
      if (!isDetailModelSheetOpen) ...[
        DASTableColumn(
          id: ColumnDefinition.kilometre.index,
          child: Text(context.l10n.p_train_journey_table_kilometre_label),
          width: 64.0,
        ),
        DASTableColumn(
          id: ColumnDefinition.gradientDownhill.index,
          child: Text('-'),
          width: 40.0,
        ),
        DASTableColumn(
          id: ColumnDefinition.gradientUphill.index,
          child: Text('+'),
          width: 40.0,
        ),
      ],
      DASTableColumn(
          id: ColumnDefinition.time.index,
          child: StreamBuilder(
              stream: timeViewModel.rxShowOperationalTime,
              builder: (context, showCalcTimeSnap) => Text(showCalcTimeSnap.data ?? false
                  ? context.l10n.p_train_journey_table_time_label_new
                  : context.l10n.p_train_journey_table_time_label_planned)),
          width: 100.0,
          onTap: () {
            final viewModel = context.read<ArrivalDepartureTimeViewModel>();
            viewModel.toggleOperationalTime();
          }),
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
        child: Text(speedLabel),
        width: 62.0,
        onTap: () => _onBreakSeriesTap(context, metadata, settings),
        headerKey: breakingSeriesHeaderKey,
      ),
      DASTableColumn(
        id: ColumnDefinition.advisedSpeed.index,
        child: Text(context.l10n.p_train_journey_table_advised_speed_label),
        width: 62.0,
      ),
      DASTableColumn(id: ColumnDefinition.actionsCell.index, width: 40.0), // actions
    ];
  }

  void _onFootNoteExpanded(BuildContext context, BaseFootNote footNote, TrainJourneySettings settings) {
    final newList = List<String>.from(settings.collapsedFootNotes);
    if (settings.collapsedFootNotes.contains(footNote.identifier)) {
      newList.remove(footNote.identifier);
    } else {
      newList.add(footNote.identifier);
    }

    context.trainJourneyCubit.updateCollapsedFootnotes(newList);
  }

  void _onBaliseLevelCrossingGroupTap(
      BuildContext context, BaliseLevelCrossingGroup group, TrainJourneySettings settings) {
    final newList = List<int>.from(settings.expandedGroups);
    if (settings.expandedGroups.contains(group.order)) {
      newList.remove(group.order);
    } else {
      newList.add(group.order);
    }

    context.trainJourneyCubit.updateExpandedGroups(newList);
  }

  Future<void> _onBreakSeriesTap(BuildContext context, Metadata metadata, TrainJourneySettings settings) async {
    final trainJourneyCubit = context.trainJourneyCubit;

    final selectedBreakSeries = await showSBBModalSheet<BreakSeries>(
      context: context,
      title: context.l10n.p_train_journey_break_series,
      constraints: BoxConstraints(),
      child: BreakSeriesSelection(
        availableBreakSeries: metadata.availableBreakSeries,
        selectedBreakSeries: settings.resolvedBreakSeries(metadata),
      ),
    );

    if (selectedBreakSeries != null) {
      trainJourneyCubit.updateBreakSeries(selectedBreakSeries);
    }
  }

  bool _isCurvePointWithoutSpeed(BaseData data, Journey journey, TrainJourneySettings settings) {
    final breakSeries = settings.resolvedBreakSeries(journey.metadata);

    return data.type == Datatype.curvePoint &&
        data.localSpeedData?.speedsFor(breakSeries?.trainSeries, breakSeries?.breakSeries) == null;
  }
}

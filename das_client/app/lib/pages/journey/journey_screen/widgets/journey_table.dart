import 'dart:io';

import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/journey_overview.dart';
import 'package:app/pages/journey/journey_screen/view_model/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_advancement_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/brake_series_selection.dart';
import 'package:app/pages/journey/journey_screen/widgets/chevron_animation_wrapper.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/additional_speed_restriction_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/balise_level_crossing_group_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/balise_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cab_signaling_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/column_definition.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/combined_foot_note_operational_indication_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/communication_network_change_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/config/bracket_station_render_data.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/config/chevron_animation_data.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/config/journey_config.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/config/track_equipment_render_data.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/connection_track_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/curve_point_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/foot_note_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/level_crossing_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/loading_table.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/protection_section_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/service_point_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/shunting_movement_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/signal_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/speed_change_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/train_driver_turnover_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/tram_area_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/uncoded_operational_indication_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/whistle_row.dart';
import 'package:app/pages/journey/view_model/decisive_gradient_view_model.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:app/provider/user_settings.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:app/widgets/table/das_table_column.dart';
import 'package:app/widgets/table/row/das_table_row_builder.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class JourneyTable extends StatelessWidget {
  const JourneyTable({super.key});

  static const Key loadedJourneyTableKey = Key('loadedJourneyTable');
  static const Key brakeSeriesHeaderKey = Key('brakeSeriesHeader');
  static const Key differentBrakeSeriesWarningKey = Key('differentBrakeSeriesWarning');

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JourneyViewModel>();
    final journeySettingsVM = context.read<JourneySettingsViewModel>();
    final advancementViewModel = context.read<JourneyTableAdvancementViewModel>();
    final decisiveGradientVM = context.read<DecisiveGradientViewModel>();

    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream.list([
        viewModel.journey,
        journeySettingsVM.model,
        decisiveGradientVM.showDecisiveGradient,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?[0] == null) {
          return JourneyLoadingTable(columns: _columns(context, null, null, null));
        }

        final journey = snapshot.data![0] as Journey;
        final settings = snapshot.data![1] as JourneySettings;

        final servicePointModalViewModel = context.read<ServicePointModalViewModel>();
        servicePointModalViewModel.updateMetadata(journey.metadata);
        servicePointModalViewModel.updateSettings(settings);

        return KeyedSubtree(
          key: loadedJourneyTableKey,
          child: Listener(
            onPointerDown: (_) => advancementViewModel.resetIdleScrollTimer(),
            onPointerUp: (_) => advancementViewModel.resetIdleScrollTimer(),
            child: _body(context, journey, settings),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, Journey journey, JourneySettings settings) {
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
        context.read<JourneyViewModel>().journeyTableScrollController.updateRenderedRows(tableRows);

        final marginAdjustment = Platform.isIOS
            ? tableRows.lastWhereOrNull((it) => it.stickyLevel == .first)?.height ?? CellRowBuilder.rowHeight
            : 0.0;

        final detailModalViewModel = context.read<DetailModalViewModel>();

        return Padding(
          padding: const .symmetric(horizontal: JourneyOverview.horizontalPadding),
          child: StreamBuilder(
            stream: detailModalViewModel.openModalType,
            builder: (context, snapshot) {
              final openModalType = snapshot.data;
              final journeyTableScrollController = context.read<JourneyViewModel>().journeyTableScrollController;
              return ChevronAnimationWrapper(
                journeyPosition: journeyPosition,
                child: DASTable(
                  key: journeyTableScrollController.tableKey,
                  scrollController: journeyTableScrollController.scrollController,
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
    final currentBrakeSeries = settings.currentBrakeSeries;
    final navigationVM = DI.get<JourneyNavigationViewModel>();

    final rows = journey.data
        .whereNot((it) => _isCurvePointWithoutSpeed(it, journey, settings))
        .hideJourneyPointsThatShouldNotBeDisplayed()
        .groupBaliseAndLevelCrossings(settings.expandedGroups, journey.metadata)
        .hideCommunicationNetworkChangesWithSameTypeAsPreviousOrIsServicePoint()
        .hideRepeatedLineFootNotes(journeyPosition.currentPosition)
        .hideFootNotesForNotSelectedTrainSeries(currentBrakeSeries?.trainSeries)
        .combineFootNoteAndOperationalIndication()
        .addTrainDriverTurnoverRows(navigationVM.modelValue?.trainIdentification)
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
          currentBrakeSeries,
        ),
        bracketStationRenderData: BracketStationRenderData.from(rowData, journey.metadata),
        chevronAnimationData: ChevronAnimationData.from(
          journeyPoints,
          journeyPosition,
          journey.metadata,
          rowData,
          currentBrakeSeries,
          settings.expandedGroups,
        ),
      );

      var hasPreviousAnnotation = false;
      if (index > 0) {
        final previous = rows[index - 1];
        hasPreviousAnnotation = previous is JourneyAnnotation;
      }

      switch (rowData.dataType) {
        case .servicePoint:
          return ServicePointRow(
            metadata: journey.metadata,
            data: rowData as ServicePoint,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            context: context,
            rowIndex: index,
          );
        case .protectionSection:
          return ProtectionSectionRow(
            metadata: journey.metadata,
            data: rowData as ProtectionSection,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case .curvePoint:
          return CurvePointRow(
            metadata: journey.metadata,
            data: rowData as CurvePoint,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case .signal:
          return SignalRow(
            metadata: journey.metadata,
            data: rowData as Signal,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case .additionalSpeedRestriction:
          return AdditionalSpeedRestrictionRow(
            metadata: journey.metadata,
            data: rowData as AdditionalSpeedRestrictionData,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            onTap: () => _onAdditionalSpeedRestrictionTap(context, rowData),
            rowIndex: index,
          );
        case .connectionTrack:
          return ConnectionTrackRow(
            metadata: journey.metadata,
            data: rowData as ConnectionTrack,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case .speedChange:
          return SpeedChangeRow(
            metadata: journey.metadata,
            data: rowData as SpeedChange,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case .cabSignaling:
          return CABSignalingRow(
            metadata: journey.metadata,
            data: rowData as CABSignaling,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case .balise:
          return BaliseRow(
            metadata: journey.metadata,
            data: rowData as Balise,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            isGrouped: groupedRows.contains(rowData),
            rowIndex: index,
          );
        case .whistle:
          return WhistleRow(
            metadata: journey.metadata,
            data: rowData as Whistle,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case .levelCrossing:
          return LevelCrossingRow(
            metadata: journey.metadata,
            data: rowData as LevelCrossing,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            isGrouped: groupedRows.contains(rowData),
            rowIndex: index,
          );
        case .tramArea:
          return TramAreaRow(
            metadata: journey.metadata,
            data: rowData as TramArea,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
          );
        case .baliseLevelCrossingGroup:
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
        case .opFootNote || .lineFootNote || .trackFootNote:
          return FootNoteRow(
            metadata: journey.metadata,
            data: rowData as BaseFootNote,
            config: journeyConfig,
            isExpanded: collapsedRows.stateOf(rowData) != .collapsed,
            addTopMargin: !hasPreviousAnnotation,
            rowIndex: index,
          );
        case .uncodedOperationalIndication:
          return UncodedOperationalIndicationRow(
            metadata: journey.metadata,
            data: rowData as UncodedOperationalIndication,
            config: journeyConfig,
            collapsedState: collapsedRows.stateOf(rowData),
            addTopMargin: !hasPreviousAnnotation,
            rowIndex: index,
          );
        case .combinedFootNoteOperationalIndication:
          return CombinedFootNoteOperationalIndicationRow(
            rowIndex: index,
            metadata: journey.metadata,
            data: rowData as CombinedFootNoteOperationalIndication,
            footNoteState: collapsedRows.stateOf(rowData.footNote),
            operationIndicationState: collapsedRows.stateOf(rowData.operationalIndication),
          );
        case .communicationNetworkChannel:
          return CommunicationNetworkChangeRow(
            metadata: journey.metadata,
            data: rowData as CommunicationNetworkChange,
            journeyPosition: journeyPosition,
            config: journeyConfig,
            rowIndex: index,
            context: context,
          );
        case .shuntingMovement:
          return ShuntingMovementRow(
            metadata: journey.metadata,
            data: rowData as ShuntingMovement,
            rowIndex: index,
          );
        case Datatype.trainDriverTurnover:
          return TrainDriverTurnoverRow(
            metadata: journey.metadata,
            data: rowData as TrainDriverTurnover,
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
    final currentBrakeSeries = settings?.currentBrakeSeries;

    final decisiveGradientVM = context.read<DecisiveGradientViewModel>();
    final timeViewModel = context.read<ArrivalDepartureTimeViewModel>();
    final userSettings = DI.get<UserSettings>();

    return [
      if (openModalType == null || openModalType == .additionalSpeedRestriction) ...[
        if (userSettings.showDecisiveGradient ||
            (!userSettings.showDecisiveGradient && !decisiveGradientVM.showDecisiveGradientValue))
          DASTableColumn(
            id: ColumnDefinition.kilometre.index,
            child: Text(context.l10n.p_journey_table_kilometre_label),
            width: 64.0,
            onTap: !userSettings.showDecisiveGradient ? () => decisiveGradientVM.toggleShowDecisiveGradient() : null,
          ),
        if (userSettings.showDecisiveGradient || decisiveGradientVM.showDecisiveGradientValue) ...[
          DASTableColumn(
            id: ColumnDefinition.gradientDownhill.index,
            child: Text('-'),
            width: 40.0,
            onTap: !userSettings.showDecisiveGradient ? () => decisiveGradientVM.toggleShowDecisiveGradient() : null,
          ),
          DASTableColumn(
            id: ColumnDefinition.gradientUphill.index,
            child: Text('+'),
            width: 40.0,
            onTap: !userSettings.showDecisiveGradient ? () => decisiveGradientVM.toggleShowDecisiveGradient() : null,
          ),
        ],
      ],
      if (openModalType == null || openModalType != .additionalSpeedRestriction)
        DASTableColumn(
          id: ColumnDefinition.time.index,
          child: StreamBuilder(
            stream: timeViewModel.showOperationalTime,
            builder: (context, showCalcTimeSnap) => Text(
              showCalcTimeSnap.data ?? false
                  ? context.l10n.p_journey_table_time_label_new
                  : context.l10n.p_journey_table_time_label_planned,
            ),
          ),
          width: 110.0,
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
        child: Text(context.l10n.p_journey_table_journey_information_label),
        expanded: true,
        alignment: .centerLeft,
      ),
      DASTableColumn(id: ColumnDefinition.icons2.index, width: 68.0), // icons column
      DASTableColumn(id: ColumnDefinition.icons3.index, width: 48.0), // icons column
      DASTableColumn(
        id: ColumnDefinition.localSpeed.index,
        child: Text(context.l10n.p_journey_table_graduated_speed_label),
        width: 100.0,
        decoration: DASTableColumnDecoration(
          border: Border(
            right: BorderSide(color: ThemeUtil.getDASTableBorderColor(context), width: 2.0),
          ),
        ),
      ),
      DASTableColumn(
        id: ColumnDefinition.brakedWeightSpeed.index,
        child: _brakedWeightSpeedHeader(context, currentBrakeSeries),
        padding: EdgeInsets.zero,
        width: 62.0,
        onTap: () => _onBrakeSeriesTap(context, metadata, settings),
        headerKey: brakeSeriesHeaderKey,
      ),
      DASTableColumn(
        id: ColumnDefinition.advisedSpeed.index,
        child: Text(context.l10n.p_journey_table_advised_speed_label),
        width: 62.0,
      ),
    ];
  }

  Widget _brakedWeightSpeedHeader(BuildContext context, BrakeSeries? currentBrakeSeries) {
    final brakeLoadSlipVM = context.read<BrakeLoadSlipViewModel>();

    return StreamBuilder(
      stream: brakeLoadSlipVM.formationRun,
      initialData: brakeLoadSlipVM.formationRunValue,
      builder: (context, _) {
        return brakeLoadSlipVM.isJourneyAndActiveFormationRunBrakeSeriesDifferent()
            ? _brakedWeightHeaderNotification(context, currentBrakeSeries)
            : Text(
                currentBrakeSeries?.name ?? '??',
                style: sbbTextStyle.lightStyle.small,
              );
      },
    );
  }

  Stack _brakedWeightHeaderNotification(BuildContext context, BrakeSeries? currentBrakeSeries) {
    return Stack(
      key: differentBrakeSeriesWarningKey,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -2,
          left: -SBBSpacing.xSmall,
          right: -2,
          bottom: -2,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: SBBColors.peach, width: SBBSpacing.xSmall),
                top: BorderSide(color: SBBColors.peach, width: 2),
                right: BorderSide(color: SBBColors.peach, width: 2),
                bottom: BorderSide(color: SBBColors.peach, width: 2),
              ),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(SBBSpacing.small),
                right: Radius.circular(SBBSpacing.xSmall),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentBrakeSeries?.name ?? '??',
                  style: sbbTextStyle.boldStyle.small,
                ),
                SvgPicture.asset(
                  AppAssets.iconSignExclamationPoint,
                  colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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

    context.read<JourneySettingsViewModel>().updateExpandedGroups(newList);
  }

  Future<void> _onBrakeSeriesTap(BuildContext context, Metadata? metadata, JourneySettings? settings) async {
    final viewModel = context.read<JourneySettingsViewModel>();

    final selectedBrakeSeries = await showSBBModalSheet<BrakeSeries>(
      context: context,
      title: context.l10n.p_journey_brake_series,
      constraints: BoxConstraints(),
      child: BrakeSeriesSelection(
        availableBrakeSeries: metadata?.availableBrakeSeries ?? {},
        selectedBrakeSeries: settings?.currentBrakeSeries,
      ),
    );

    if (selectedBrakeSeries != null) viewModel.updateBrakeSeries(selectedBrakeSeries);
  }

  bool _isCurvePointWithoutSpeed(BaseData data, Journey journey, JourneySettings settings) {
    final brakeSeries = settings.currentBrakeSeries;

    return data is CurvePoint &&
        data.localSpeeds?.speedFor(brakeSeries?.trainSeries, brakeSeries: brakeSeries?.brakeSeries) == null;
  }

  void _onAdditionalSpeedRestrictionTap(BuildContext context, AdditionalSpeedRestrictionData data) {
    final viewModel = context.read<AdditionalSpeedRestrictionModalViewModel>();
    viewModel.open(context, data.restrictions);
  }
}

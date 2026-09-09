import 'package:app/di/di.dart';
import 'package:app/extension/base_data_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/model/reduced_journey_table_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/view_model/reduced_overview_view_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/widgets/rows/reduced_communication_network_change_row.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/widgets/rows/reduced_service_point_row.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/widgets/rows/reduced_signal_row.dart';
import 'package:app/pages/journey/journey_screen/view_model/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/chevron_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/additional_speed_restriction_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/column_definition.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/combined_foot_note_and_indications.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/combined_foot_note_and_indications_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/config/bracket_station_render_data.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/config/journey_config.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/curve_point_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/indication_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/protection_section_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/speed_change_row.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/accordion/accordion.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:app/widgets/table/das_table_column.dart';
import 'package:app/widgets/table/row/das_table_row_builder.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:ru_indications/component.dart';
import 'package:sfera/component.dart';

final _log = Logger('ReducedJourneyTable');

class ReducedJourneyTable extends StatelessWidget {
  static const Key reducedJourneyTableKey = Key('reducedJourneyTable');

  const ReducedJourneyTable({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ReducedOverviewViewModel>();
    return StreamBuilder<ReducedJourneyTableModel>(
      stream: viewModel.model,
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data is! ReducedTableLoaded) {
          return Center(child: CircularProgressIndicator());
        }

        return _body(context, snapshot.data as ReducedTableLoaded);
      },
    );
  }

  Widget _body(
    BuildContext context,
    ReducedTableLoaded model,
  ) {
    final columns = _columns(context);

    return DASTable(
      key: reducedJourneyTableKey,
      columns: columns,
      rows: _rows(
        context,
        model,
        columns.leftOffsetTo(columnId: ColumnDefinition.informationCell.index),
      ).map((it) => it.build(context)).toList(),
      hasStickyRows: false,
      addBottomSpacer: false,
    );
  }

  /// GlobalKey needs to be set for rows on reduced overview. Otherwise it would collide with default key generated in [DASTableRowBuilder].
  List<DASTableRowBuilder> _rows(
    BuildContext context,
    ReducedTableLoaded model,
    double leftOffsetToInformationCell,
  ) {
    final settingsVM = DI.get<JourneySettingsViewModel>();

    final baseData = model.journeyTableRowData
        .hideCommunicationNetworkChangesWithSameTypeAsPreviousOrIsServicePoint()
        .hideIndicationsForHiddenServicePoint()
        .combineFootNoteAndIndications()
        .sorted(
          (a1, a2) => a1.compareTo(a2),
        );

    final journeyPosition = JourneyPositionModel();
    final chevronPosition = ChevronPositionModel();

    final List<DASTableRowBuilder?> builders = List.generate(baseData.length, (rowIndex) {
      final rowData = baseData[rowIndex];

      final journeyConfig = JourneyConfig(
        bracketStationRenderData: BracketStationRenderData.from(data: rowData, metadata: model.journeyMetadata),
        settings: settingsVM.modelValue,
      );

      switch (rowData.dataType) {
        case .servicePoint:
          final servicePoint = rowData as ServicePoint;
          return ReducedServicePointRow(
            key: GlobalKey(),
            metadata: model.journeyMetadata,
            data: servicePoint,
            config: journeyConfig,
            context: context,
            rowIndex: rowIndex,
            routeVariant: model.variantsByOrder[servicePoint.order],
          );
        case .additionalSpeedRestriction:
          return AdditionalSpeedRestrictionRow(
            key: GlobalKey(),
            metadata: model.journeyMetadata,
            data: rowData as AdditionalSpeedRestrictionData,
            journeyPosition: journeyPosition,
            chevronPosition: chevronPosition,
            config: journeyConfig,
            rowIndex: rowIndex,
          );
        case .communicationNetworkChannel:
          return ReducedCommunicationNetworkChangeRow(
            key: GlobalKey(),
            metadata: model.journeyMetadata,
            data: rowData as CommunicationNetworkChange,
            rowIndex: rowIndex,
            context: context,
          );
        case .curvePoint:
          return CurvePointRow(
            metadata: model.journeyMetadata,
            data: rowData as CurvePoint,
            rowIndex: rowIndex,
            journeyPosition: journeyPosition,
            chevronPosition: chevronPosition,
            showModificationOnInformationCell: true,
          );
        case .protectionSection:
          return ProtectionSectionRow(
            metadata: model.journeyMetadata,
            data: rowData as ProtectionSection,
            rowIndex: rowIndex,
            journeyPosition: journeyPosition,
            chevronPosition: chevronPosition,
            showModificationOnInformationCell: true,
          );
        case .signal:
          return ReducedSignalRow(
            metadata: model.journeyMetadata,
            data: rowData as Signal,
            rowIndex: rowIndex,
            journeyPosition: journeyPosition,
            chevronPosition: chevronPosition,
          );
        case .speedChange:
          return SpeedChangeRow(
            metadata: model.journeyMetadata,
            data: rowData as SpeedChange,
            rowIndex: rowIndex,
            journeyPosition: journeyPosition,
            chevronPosition: chevronPosition,
            showModificationOnInformationCell: true,
          );
        case .operationalIndication:
          return IndicationRow(
            rowIndex: rowIndex,
            metadata: model.journeyMetadata,
            data: rowData as OperationalIndication,
            collapsedState: model.collapsedRows.stateOf(rowData),
            leftPadding: leftOffsetToInformationCell - Accordion.contentPadding,
          );
        case .ruIndication:
          return IndicationRow(
            rowIndex: rowIndex,
            metadata: model.journeyMetadata,
            data: rowData as RuIndication,
            config: journeyConfig,
            collapsedState: model.collapsedRows.stateOf(rowData),
            leftPadding: leftOffsetToInformationCell - Accordion.contentPadding,
          );
        case .combinedFootNoteAndIndications:
          return CombinedFootNoteAndIndicationsRow(
            rowIndex: rowIndex,
            metadata: model.journeyMetadata,
            data: rowData as CombinedFootNoteAndIndications,
            footNoteState: model.collapsedRows.stateOf(rowData.footNote),
            indicationStates: model.collapsedRows.whereContains(rowData.indications),
            leftPadding: leftOffsetToInformationCell - Accordion.contentPadding,
          );
        default:
          _log.fine('Row type ${rowData.dataType} is not supported in reduced overview');
          return null;
      }
    });

    return builders.nonNulls.toList();
  }

  List<DASTableColumn> _columns(BuildContext context) {
    final arrivalDepartureTimeViewModel = context.read<ArrivalDepartureTimeViewModel>();

    return [
      DASTableColumn(
        id: ColumnDefinition.time.index,
        child: StreamBuilder(
          stream: arrivalDepartureTimeViewModel.showOperationalTime,
          builder: (context, showOperationalTimeSnap) => Text(
            showOperationalTimeSnap.data ?? false
                ? context.l10n.p_journey_table_time_label_new
                : context.l10n.p_journey_table_time_label_planned,
          ),
        ),
        width: 111.0,
        onTap: () => arrivalDepartureTimeViewModel.toggleOperationalTime(),
      ),
      DASTableColumn(id: ColumnDefinition.route.index, width: 48.0), // route column
      DASTableColumn(width: 10.0), // spacer column so bracketStation does not overlap
      DASTableColumn(id: ColumnDefinition.bracketStation.index, width: 0.0), // bracket station column
      DASTableColumn(
        id: ColumnDefinition.informationCell.index,
        expanded: true,
        alignment: .centerLeft,
        child: Text(context.l10n.p_journey_table_journey_information_label),
      ),
      DASTableColumn(id: ColumnDefinition.icons2.index, width: 48.0), // icons column
      DASTableColumn(
        id: ColumnDefinition.localSpeed.index,
        width: 100.0,
        decoration: DASTableColumnDecoration(
          border: Border(
            right: BorderSide(color: ThemeUtil.getDASTableBorderColor(context), width: 2.0),
          ),
        ),
      ),
      DASTableColumn(
        id: ColumnDefinition.communicationNetwork.index,
        width: 80.0,
        child: Text(context.l10n.p_journey_table_communication_network),
      ),
    ];
  }
}

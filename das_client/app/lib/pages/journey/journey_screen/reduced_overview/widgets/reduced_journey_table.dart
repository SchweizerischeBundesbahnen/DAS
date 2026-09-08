import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/reduced_overview_view_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/widgets/rows/reduced_communication_network_change_row.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/widgets/rows/reduced_service_point_row.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/widgets/rows/reduced_signal_row.dart';
import 'package:app/pages/journey/journey_screen/view_model/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/chevron_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/route_variant_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/additional_speed_restriction_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/column_definition.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/config/bracket_station_render_data.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/config/journey_config.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/curve_point_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/protection_section_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/speed_change_row.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:app/widgets/table/das_table_column.dart';
import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('ReducedJourneyTable');

class ReducedJourneyTable extends StatelessWidget {
  static const Key reducedJourneyTableKey = Key('reducedJourneyTable');

  const ReducedJourneyTable({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ReducedOverviewViewModel>();
    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream.list([viewModel.journeyData, viewModel.journeyMetadata]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data![0] as List<BaseData>;
        final metadata = snapshot.data![1] as Metadata;

        return _body(context, metadata, data);
      },
    );
  }

  Widget _body(BuildContext context, Metadata metadata, List<BaseData> data) {
    final rows = data.hideCommunicationNetworkChangesWithSameTypeAsPreviousOrIsServicePoint().sorted(
      (a1, a2) => a1.compareTo(a2),
    );

    return DASTable(
      key: reducedJourneyTableKey,
      columns: _columns(context),
      rows: _rows(context, metadata, rows).map((it) => it.build(context)).toList(),
      hasStickyRows: false,
      addBottomSpacer: false,
    );
  }

  /// GlobalKey needs to be set for rows on reduced overview. Otherwise it would collide with default key generated in [DASTableRowBuilder].
  List<CellRowBuilder> _rows(
    BuildContext context,
    Metadata metadata,
    List<BaseData> baseData,
  ) {
    final settingsVM = DI.get<JourneySettingsViewModel>();
    final routeVariantVM = context.read<RouteVariantViewModel>();

    final journeyPosition = JourneyPositionModel();
    final chevronPosition = ChevronPositionModel();

    final List<CellRowBuilder?> builders = List.generate(baseData.length, (rowIndex) {
      final rowData = baseData[rowIndex];

      final journeyConfig = JourneyConfig(
        bracketStationRenderData: BracketStationRenderData.from(data: rowData, metadata: metadata),
        settings: settingsVM.modelValue,
      );

      switch (rowData.dataType) {
        case .servicePoint:
          return ReducedServicePointRow(
            key: GlobalKey(),
            metadata: metadata,
            data: rowData as ServicePoint,
            config: journeyConfig,
            context: context,
            rowIndex: rowIndex,
            routeVariant: routeVariantVM.getRouteVariant(rowData),
          );
        case .additionalSpeedRestriction:
          return AdditionalSpeedRestrictionRow(
            key: GlobalKey(),
            metadata: metadata,
            data: rowData as AdditionalSpeedRestrictionData,
            journeyPosition: journeyPosition,
            chevronPosition: chevronPosition,
            config: journeyConfig,
            rowIndex: rowIndex,
          );
        case .communicationNetworkChannel:
          return ReducedCommunicationNetworkChangeRow(
            key: GlobalKey(),
            metadata: metadata,
            data: rowData as CommunicationNetworkChange,
            rowIndex: rowIndex,
            context: context,
          );
        case .curvePoint:
          return CurvePointRow(
            metadata: metadata,
            data: rowData as CurvePoint,
            rowIndex: rowIndex,
            journeyPosition: journeyPosition,
            chevronPosition: chevronPosition,
            showModificationOnInformationCell: true,
          );
        case .protectionSection:
          return ProtectionSectionRow(
            metadata: metadata,
            data: rowData as ProtectionSection,
            rowIndex: rowIndex,
            journeyPosition: journeyPosition,
            chevronPosition: chevronPosition,
            showModificationOnInformationCell: true,
          );
        case .signal:
          return ReducedSignalRow(
            metadata: metadata,
            data: rowData as Signal,
            rowIndex: rowIndex,
            journeyPosition: journeyPosition,
            chevronPosition: chevronPosition,
          );
        case .speedChange:
          return SpeedChangeRow(
            metadata: metadata,
            data: rowData as SpeedChange,
            rowIndex: rowIndex,
            journeyPosition: journeyPosition,
            chevronPosition: chevronPosition,
            showModificationOnInformationCell: true,
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

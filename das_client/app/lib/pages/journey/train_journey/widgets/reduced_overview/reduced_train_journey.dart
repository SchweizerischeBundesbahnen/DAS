import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/reduced_overview/reduced_overview_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/reduced_overview/rows/reduced_service_point_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/additional_speed_restriction_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/table/column_definition.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/bracket_station_render_data.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_config.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:app/widgets/table/das_table_column.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class ReducedTrainJourney extends StatelessWidget {
  static const Key reducedJourneyTableKey = Key('reducedJourneyTable');

  const ReducedTrainJourney({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ReducedOverviewViewModel>();
    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream.list([viewModel.journeyData, viewModel.journeyMetadata]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: SBBLoadingIndicator.tiny());
        }

        final data = snapshot.data![0] as List<BaseData>;
        final metadata = snapshot.data![1] as Metadata;

        return _body(context, metadata, data);
      },
    );
  }

  Widget _body(BuildContext context, Metadata metadata, List<BaseData> data) {
    return DASTable(
      key: reducedJourneyTableKey,
      columns: _columns(context),
      rows: _rows(context, metadata, data).map((it) => it.build(context)).toList(),
      alignToItem: false,
      hasStickyWidgets: false,
    );
  }

  List<CellRowBuilder> _rows(BuildContext context, Metadata metadata, List<BaseData> data) {
    final List<CellRowBuilder?> builders = List.generate(data.length, (index) {
      final rowData = data[index];
      final trainJourneyConfig = TrainJourneyConfig(
        bracketStationRenderData: BracketStationRenderData.from(rowData, metadata),
      );

      switch (rowData.type) {
        case Datatype.servicePoint:
          return ReducedServicePointRow(
            metadata: metadata,
            data: rowData as ServicePoint,
            config: trainJourneyConfig,
            context: context,
            rowIndex: index,
          );
        case Datatype.additionalSpeedRestriction:
          return AdditionalSpeedRestrictionRow(
            metadata: metadata,
            data: rowData as AdditionalSpeedRestrictionData,
            config: trainJourneyConfig,
            rowIndex: index,
          );
        default:
          return null;
      }
    });

    return builders.nonNulls.toList();
  }

  List<DASTableColumn> _columns(BuildContext context) {
    return [
      DASTableColumn(
        id: ColumnDefinition.time.index,
        width: 100.0,
        child: Text(context.l10n.p_train_journey_table_time_label_planned),
      ),
      DASTableColumn(id: ColumnDefinition.route.index, width: 48.0), // route column
      DASTableColumn(width: 10.0), // spacer column so bracketStation does not overlap
      DASTableColumn(id: ColumnDefinition.bracketStation.index, width: 0.0), // bracket station column
      DASTableColumn(
        id: ColumnDefinition.informationCell.index,
        expanded: true,
        alignment: Alignment.centerLeft,
        child: Text(context.l10n.p_train_journey_table_journey_information_label),
      ),
      DASTableColumn(id: ColumnDefinition.icons2.index, width: 48.0), // icons column
      DASTableColumn(
        id: ColumnDefinition.localSpeed.index,
        width: 100.0,
        border: BorderDirectional(
          bottom: BorderSide(color: ThemeUtil.getDASTableBorderColor(context), width: 1.0),
          end: BorderSide(color: ThemeUtil.getDASTableBorderColor(context), width: 2.0),
        ),
      ),
      DASTableColumn(
        id: ColumnDefinition.communicationNetwork.index,
        width: 80.0,
        child: Text(context.l10n.p_train_journey_table_communication_network),
      ),
    ];
  }
}

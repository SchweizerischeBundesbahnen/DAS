import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/journey_overview.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/chevron_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/column_definition.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/das_table_column.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Skeletonized DAS Table for loading state
class JourneyLoadingTable extends StatelessWidget {
  const JourneyLoadingTable({
    required this.columns,
    super.key,
  });

  factory JourneyLoadingTable.withDefaults(BuildContext context, {Key? key}) {
    return JourneyLoadingTable(
      key: key,
      columns: defaultColumns(context),
    );
  }

  final List<DASTableColumn> columns;

  static List<DASTableColumn> defaultColumns(BuildContext context) {
    return [
      DASTableColumn(
        id: ColumnDefinition.kilometre.index,
        child: Text(context.l10n.p_journey_table_kilometre_label),
        width: 66.0,
      ),
      DASTableColumn(
        id: ColumnDefinition.time.index,
        child: Text(context.l10n.p_journey_table_time_label_planned),
        width: 111.0,
      ),
      DASTableColumn(id: ColumnDefinition.route.index, width: 48.0),
      DASTableColumn(id: ColumnDefinition.trackEquipment.index, width: 20.0),
      DASTableColumn(id: ColumnDefinition.icons1.index, width: 64.0),
      DASTableColumn(id: ColumnDefinition.bracketStation.index, width: 0.0),
      DASTableColumn(
        id: ColumnDefinition.informationCell.index,
        child: Text(context.l10n.p_journey_table_journey_information_label),
        expanded: true,
        alignment: Alignment.centerLeft,
      ),
      DASTableColumn(id: ColumnDefinition.icons2.index, width: 68.0),
      DASTableColumn(id: ColumnDefinition.icons3.index, width: 48.0),
      DASTableColumn(
        id: ColumnDefinition.localSpeed.index,
        child: Text(context.l10n.p_journey_table_graduated_speed_label),
        width: 100.0,
      ),
      DASTableColumn(
        id: ColumnDefinition.brakedWeightSpeed.index,
        child: const SizedBox.shrink(),
        width: 62.0,
      ),
      DASTableColumn(
        id: ColumnDefinition.advisedSpeed.index,
        child: const SizedBox.shrink(),
        width: 60.0,
      ),
      DASTableColumn(
        id: ColumnDefinition.communicationNetwork.index,
        child: const SizedBox.shrink(),
        width: 40.0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: JourneyOverview.horizontalPadding),
      child: Skeletonizer(
        enabled: true,
        child: DASTable(
          columns: columns,
          rows: List.generate(20, (index) => _EmptyLoadingRow(rowIndex: index).build(context)),
        ),
      ),
    );
  }
}

class _EmptyLoadingRow extends CellRowBuilder<JourneyPoint> {
  _EmptyLoadingRow({required super.rowIndex})
    : super(
        metadata: Metadata(),
        data: CABSignaling(order: 0, kilometre: []),
        journeyPosition: JourneyPositionModel(),
        chevronPosition: ChevronPositionModel(),
      );

  @override
  DASTableCell kilometreCell(BuildContext context) => DASTableCell(child: Text(BoneMock.chars(2)));

  @override
  DASTableCell routeCell(BuildContext context) => DASTableCell.empty();

  @override
  DASTableCell localSpeedCell(BuildContext context) => DASTableCell(child: Text(BoneMock.chars(2)));

  @override
  DASTableCell brakedWeightSpeedCell(BuildContext context) => DASTableCell.empty();

  @override
  DASTableCell speedCell(List<TrainSeriesSpeed>? speedData) => DASTableCell.empty();

  @override
  DASTableCell bracketStation(BuildContext context) => DASTableCell.empty();

  @override
  DASTableCell communicationNetworkCell(BuildContext context) => DASTableCell.empty();

  @override
  DASTableCell timeCell(BuildContext context) => DASTableCell(child: Text(BoneMock.words(2)));

  @override
  DASTableCell informationCell(BuildContext context) => DASTableCell(child: Text(BoneMock.words(4)));

  @override
  DASTableCell advisedSpeedCell(BuildContext context) => DASTableCell.empty();

  @override
  DASTableCell iconsCell1(BuildContext context) => DASTableCell.empty();

  @override
  DASTableCell iconsCell2(BuildContext context) => DASTableCell.empty();

  @override
  DASTableCell iconsCell3(BuildContext context) => DASTableCell.empty();

  @override
  DASTableCell gradientUphillCell(BuildContext context) => DASTableCell.empty();

  @override
  DASTableCell gradientDownhillCell(BuildContext context) => DASTableCell.empty();
}

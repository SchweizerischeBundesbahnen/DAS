import 'package:app/pages/journey/journey_table/journey_overview.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/journey_table/widgets/table/cell_row_builder.dart';
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

  final List<DASTableColumn> columns;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: JourneyOverview.horizontalPadding),
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

import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:flutter/material.dart';

abstract class BaseRowBuilder extends DASTableRowBuilder {
  const BaseRowBuilder({
    super.height,
    this.kilometre,
    this.defaultAlignment = Alignment.bottomCenter,
    this.rowColor,
    this.isCurrentPosition = false,
  });

  final List<double>? kilometre;
  final Alignment defaultAlignment;
  final Color? rowColor;
  final bool isCurrentPosition;

  @override
  DASTableRow build(BuildContext context) {
    return DASTableRow(
      height: height,
      color: rowColor,
      cells: [
        kilometreCell(context),
        timeCell(context),
        routeCell(context),
        iconsCell1(context),
        informationCell(context),
        iconsCell2(context),
        iconsCell3(context),
        graduatedSpeedCell(context),
        brakedWeightSpeedCell(context),
        advisedSpeedCell(context),
        actionsCell(context),
      ],
    );
  }

  DASTableCell kilometreCell(BuildContext context) {
    if (kilometre == null || kilometre!.isEmpty) {
      return DASTableCell.empty();
    }

    return DASTableCell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kilometre![0].toStringAsFixed(1)),
            if (kilometre!.length > 1) Text(kilometre![1].toStringAsFixed(1))
          ],
        ),
        alignment: Alignment.centerLeft);
  }

  DASTableCell timeCell(BuildContext context) {
    return DASTableCell(child: Text('06:05:52'), alignment: defaultAlignment);
  }

  DASTableCell routeCell(BuildContext context) {
    return DASTableCell(
      padding: EdgeInsets.all(0.0),
      alignment: null,
      child: RouteCellBody(isCurrentPosition: isCurrentPosition),
    );
  }

  DASTableCell informationCell(BuildContext context) {
    return DASTableCell.empty();
  }

  DASTableCell graduatedSpeedCell(BuildContext context) {
    return DASTableCell(child: Text('85'), alignment: defaultAlignment);
  }

  DASTableCell advisedSpeedCell(BuildContext context) {
    return DASTableCell(child: Text('100'), alignment: defaultAlignment);
  }

  DASTableCell brakedWeightSpeedCell(BuildContext context) {
    return DASTableCell(child: Text('95'), alignment: defaultAlignment);
  }

  // TODO: clarify use of different icon cells and set appropriate name
  DASTableCell iconsCell1(BuildContext context) {
    return DASTableCell.empty();
  }

  // TODO: clarify use of different icon cells and set appropriate name
  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell.empty();
  }

  // TODO: clarify use of different icon cells and set appropriate name
  DASTableCell iconsCell3(BuildContext context) {
    return DASTableCell.empty();
  }

  DASTableCell actionsCell(BuildContext context) {
    return DASTableCell.empty();
  }
}

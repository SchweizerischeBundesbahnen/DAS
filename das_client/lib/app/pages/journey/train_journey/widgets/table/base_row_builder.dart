import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:flutter/material.dart';

abstract class BaseRowBuilder extends DASTableRowBuilder {
  const BaseRowBuilder({
    super.height,
    this.kilometre,
    this.defaultAlignment = Alignment.centerLeft,
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
        kilometreCell(),
        timeCell(),
        routeCell(),
        iconsCell1(),
        informationCell(),
        iconsCell2(),
        iconsCell3(),
        graduatedSpeedCell(),
        brakedWeightSpeedCell(),
        advisedSpeedCell(),
        actionsCell(),
      ],
    );
  }

  DASTableCell kilometreCell() {
    if (kilometre == null || kilometre!.isEmpty) {
      return DASTableCell.empty();
    }

    return DASTableCell(child: Column(
      children: [
        Text(kilometre![0].toStringAsFixed(1)),
        if (kilometre!.length > 1)
          Text(kilometre![1].toStringAsFixed(1))
      ],
    ), alignment: defaultAlignment);
  }

  DASTableCell timeCell() {
    return DASTableCell(child: Text('06:05:52'), alignment: defaultAlignment);
  }

  DASTableCell routeCell() {
    return DASTableCell(
      padding: EdgeInsets.all(0.0),
      alignment: null,
      child: RouteCellBody(isCurrentPosition: isCurrentPosition),
    );
  }

  DASTableCell informationCell() {
    return DASTableCell.empty();
  }

  DASTableCell graduatedSpeedCell() {
    return DASTableCell(child: Text('85'), alignment: defaultAlignment);
  }

  DASTableCell advisedSpeedCell() {
    return DASTableCell(child: Text('100'), alignment: defaultAlignment);
  }

  DASTableCell brakedWeightSpeedCell() {
    return DASTableCell(child: Text('95'), alignment: defaultAlignment);
  }

  // TODO: clarify use of different icon cells and set appropriate name
  DASTableCell iconsCell1() {
    return DASTableCell.empty();
  }

  // TODO: clarify use of different icon cells and set appropriate name
  DASTableCell iconsCell2() {
    return DASTableCell.empty();
  }

  // TODO: clarify use of different icon cells and set appropriate name
  DASTableCell iconsCell3() {
    return DASTableCell.empty();
  }

  DASTableCell actionsCell() {
    return DASTableCell.empty();
  }
}

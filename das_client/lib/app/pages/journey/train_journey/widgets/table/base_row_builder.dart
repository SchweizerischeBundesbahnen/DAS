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

  final double? kilometre;
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
    if (kilometre == null) {
      return DASTableCell.empty();
    }

    var kilometreAsString = kilometre!.toStringAsFixed(3);
    kilometreAsString = kilometreAsString.replaceAll(RegExp(r'0*$'), '');
    return DASTableCell(child: Text(kilometreAsString), alignment: defaultAlignment);
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

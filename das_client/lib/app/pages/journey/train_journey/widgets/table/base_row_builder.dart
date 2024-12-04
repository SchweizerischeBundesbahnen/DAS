import 'package:das_client/app/pages/journey/train_journey/widgets/table/additional_speed_restriction_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/model/journey/additional_speed_restriction.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:flutter/material.dart';

class BaseRowBuilder<T extends BaseData> extends DASTableRowBuilder {
  static const double rowHeight = 44.0;

  const BaseRowBuilder({
    required this.metadata,
    required this.data,
    super.height = rowHeight,
    this.defaultAlignment = Alignment.bottomCenter,
    this.rowColor,
  });

  final Alignment defaultAlignment;
  final Color? rowColor;
  final Metadata metadata;
  final T data;

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
    if (data.kilometre.isEmpty) {
      return DASTableCell.empty(color: specialCellColor);
    }

    return DASTableCell(
        color: specialCellColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.kilometre[0].toStringAsFixed(1)),
            if (data.kilometre.length > 1) Text(data.kilometre[1].toStringAsFixed(1))
          ],
        ),
        alignment: Alignment.centerLeft);
  }

  DASTableCell routeCell(BuildContext context) {
    return DASTableCell(
      color: specialCellColor,
      padding: EdgeInsets.all(0.0),
      alignment: null,
      child: RouteCellBody(
        isCurrentPosition: metadata.currentPosition == data,
        isRouteStart: metadata.routeStart == data,
        isRouteEnd: metadata.routeEnd == data,
      ),
    );
  }

  DASTableCell timeCell(BuildContext context) {
    return DASTableCell.empty(color: specialCellColor);
  }

  DASTableCell informationCell(BuildContext context) {
    return DASTableCell.empty();
  }

  DASTableCell graduatedSpeedCell(BuildContext context) {
    return DASTableCell.empty();
  }

  DASTableCell advisedSpeedCell(BuildContext context) {
    return DASTableCell.empty();
  }

  DASTableCell brakedWeightSpeedCell(BuildContext context) {
    return DASTableCell.empty();
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

  Color? get specialCellColor =>
      getAdditionalSpeedRestriction() != null ? AdditionalSpeedRestrictionRow.additionalSpeedRestrictionColor : null;

  AdditionalSpeedRestriction? getAdditionalSpeedRestriction() {
    return metadata.additionalSpeedRestrictions
        .where((it) => it.orderFrom <= data.order && it.orderTo >= data.order)
        .firstOrNull;
  }
}

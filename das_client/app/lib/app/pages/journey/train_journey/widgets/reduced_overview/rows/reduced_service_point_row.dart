import 'package:app/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:app/app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:app/app/widgets/table/das_table_cell.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';

class ReducedServicePointRow extends ServicePointRow {
  ReducedServicePointRow({required super.metadata, required super.data, required this.context, super.config})
      : super(context: context, rowColor: ThemeUtil.getDASTableColor(context));

  final BuildContext context;

  @override
  DASTableCell localSpeedCell(BuildContext context) {
    return DASTableCell.empty();
  }

  @override
  DASTableCell timeCell(BuildContext context) {
    return DASTableCell(child: Text('06:05'), alignment: defaultAlignment, color: specialCellColor);
  }

  @override
  DASTableCell routeCell(BuildContext context) {
    return DASTableCell(
      color: specialCellColor,
      padding: EdgeInsets.all(0.0),
      alignment: null,
      clipBehaviour: Clip.none,
      child: RouteCellBody(
        isStop: data.isStop,
        isCurrentPosition: false,
        isRouteStart: metadata.routeStart == data,
        isRouteEnd: metadata.routeEnd == data,
        isStopOnRequest: !data.mandatoryStop,
      ),
    );
  }
}

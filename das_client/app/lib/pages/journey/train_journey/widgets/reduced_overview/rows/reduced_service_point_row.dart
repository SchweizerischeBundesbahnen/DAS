import 'package:app/extension/base_data_extension.dart';
import 'package:app/pages/journey/train_journey/widgets/reduced_overview/cells/reduced_time_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';

class ReducedServicePointRow extends ServicePointRow {
  ReducedServicePointRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required this.context,
    super.config,
  }) : super(context: context, rowColor: ThemeUtil.getDASTableColor(context), highlightNextStop: false);

  final BuildContext context;

  @override
  DASTableCell localSpeedCell(BuildContext context) {
    return DASTableCell.empty();
  }

  @override
  DASTableCell timeCell(BuildContext context) {
    final times = data.arrivalDepartureTime;
    if (times == null) return DASTableCell.empty(color: specialCellColor);

    return DASTableCell(
      child: ReducedTimeCellBody(times: times, showTimesInBrackets: !data.isStop),
      alignment: defaultAlignment,
      color: specialCellColor,
    );
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
        chevronPosition: data.chevronPosition,
        isNextStop: false,
      ),
    );
  }
}

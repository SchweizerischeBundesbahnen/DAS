import 'package:app/pages/journey/journey_screen/reduced_overview/widgets/cells/reduced_time_cell_body.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_cell_body.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/service_point_row.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';

class ReducedServicePointRow extends ServicePointRow {
  ReducedServicePointRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.context,
    super.config,
    super.key,
  }) : super(
         rowColor: ThemeUtil.getDASTableColor(context),
         journeyPosition: JourneyPositionModel(),
         highlightNextStop: false,
       );

  @override
  DASTableCell localSpeedCell(BuildContext context) {
    return DASTableCell.empty();
  }

  @override
  DASTableCell timeCell(BuildContext context) {
    final times = data.arrivalDepartureTime;
    if (times == null && data.mandatoryStop) {
      return DASTableCell.empty(
        decoration: DASTableCellDecoration(color: specialCellColor),
      );
    }

    return DASTableCell(
      child: ReducedTimeCellBody(times: times, showTimesInBrackets: !data.isStop, mandatoryStop: data.mandatoryStop),
      alignment: .bottomLeft,
      decoration: DASTableCellDecoration(color: specialCellColor),
    );
  }

  @override
  bool get shouldOpenDetailModalOnTap => false;

  @override
  DASTableCell routeCell(BuildContext context) {
    return DASTableCell(
      decoration: DASTableCellDecoration(color: specialCellColor),
      padding: .all(0.0),
      alignment: null,
      clipBehavior: .none,
      child: RouteCellBody(
        isStop: data.isStop,
        isCurrentPosition: false,
        isRouteStart: metadata.journeyStart == data,
        isRouteEnd: metadata.journeyEnd == data,
        isStopOnRequest: !data.mandatoryStop,
        chevronPosition: chevronPosition,
      ),
    );
  }

  @override
  Stream<bool> isModalOpenStream(BuildContext context) => Stream.value(false).asBroadcastStream();

  @override
  bool isModalOpenValue(BuildContext context) => false;
}

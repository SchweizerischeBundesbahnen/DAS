import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// TODO: Extract real values from SFERA objects.
class ServicePointRow extends BaseRowBuilder {
  ServicePointRow({
    super.height = 64.0,
    super.defaultAlignment = _defaultAlignment,
    super.kilometre,
    super.isCurrentPosition,
    this.isStop = true,
    this.isRouteStart = false,
    this.isRouteEnd = false,
    this.isStopOnRequest = false,
    this.timingPoint,
    this.timingPointConstraints,
    bool nextStop = false,
  }) : super(
          rowColor: nextStop ? SBBColors.royal.withOpacity(0.2) : Colors.transparent,
        );

  final TimingPoint? timingPoint;
  final TimingPointConstraints? timingPointConstraints;

  static const Alignment _defaultAlignment = Alignment.bottomCenter;

  final bool isRouteStart;
  final bool isRouteEnd;
  final bool isStopOnRequest;
  final bool isStop;

  @override
  DASTableCell informationCell() {
    final servicePointName = timingPoint?.names.first.name ?? 'Unknown';
    return DASTableCell(
      alignment: _defaultAlignment,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(servicePointName, style: SBBTextStyles.largeBold.copyWith(fontSize: 24.0)),
          Spacer(),
          Text('B12'),
        ],
      ),
    );
  }

  @override
  DASTableCell iconsCell1() {
    if (isStopOnRequest) {
      return DASTableCell(
        alignment: _defaultAlignment,
        child: SvgPicture.asset(AppAssets.iconStopOnRequest),
      );
    }

    return DASTableCell.empty();
  }

  @override
  DASTableCell routeCell() {
    return DASTableCell(
      padding: EdgeInsets.all(0.0),
      alignment: null,
      child: RouteCellBody(
        isStop: isStop,
        isCurrentPosition: isCurrentPosition,
        isRouteStart: isRouteStart,
        isRouteEnd: isRouteEnd,
        isStopOnRequest: isStopOnRequest,
      ),
    );
  }
}

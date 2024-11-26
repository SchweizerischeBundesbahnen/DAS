import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/bracket_station_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServicePointRow extends BaseRowBuilder<ServicePoint> {
  static const Key stopOnRequestKey = Key('stop_on_request_key');

  ServicePointRow({
    super.height = 64.0,
    this.isRouteStart = false,
    this.isRouteEnd = false,
    required super.metadata,
    required super.data,
  }) : super(rowColor: metadata.nextStop == data ? SBBColors.royal.withOpacity(0.2) : Colors.transparent);

  final bool isRouteStart;
  final bool isRouteEnd;

  @override
  DASTableCell informationCell(BuildContext context) {
    final servicePointName = data.name.localized;
    final textStyle = data.isStation
        ? SBBTextStyles.largeBold.copyWith(fontSize: 24.0)
        : SBBTextStyles.largeLight.copyWith(fontSize: 24.0, fontStyle: FontStyle.italic);
    return DASTableCell(
      alignment: defaultAlignment,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(servicePointName, style: textStyle),
          Spacer(),
          Text('B12'),
        ],
      ),
    );
  }

  @override
  DASTableCell iconsCell1(BuildContext context) {
    return DASTableCell(
      padding: EdgeInsets.fromLTRB(0, sbbDefaultSpacing * 0.5, 0, sbbDefaultSpacing * 0.5),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (data.bracketStation != null)
            BracketStationBody(
              bracketStation: data.bracketStation!,
              height: height!,
            ),
          if (!data.mandatoryStop)
            Align(
                alignment: Alignment.bottomCenter,
                child: SvgPicture.asset(
                  AppAssets.iconStopOnRequest,
                  key: stopOnRequestKey,
                ))
        ],
      ),
    );
  }

  @override
  DASTableCell routeCell(BuildContext context) {
    return DASTableCell(
      color: getRouteCellColor(),
      padding: EdgeInsets.all(0.0),
      alignment: null,
      child: RouteCellBody(
        isStop: data.isStop,
        isCurrentPosition: metadata.currentPosition == data,
        isRouteStart: isRouteStart,
        isRouteEnd: isRouteEnd,
        isStopOnRequest: !data.mandatoryStop,
      ),
    );
  }
}

import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/bracket_station_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// TODO: Extract real values from SFERA objects.
class ServicePointRow extends BaseRowBuilder {
  static const Key stopOnRequestKey = Key('stop_on_request_key');

  ServicePointRow({
    super.height = 66.0,
    super.defaultAlignment = _defaultAlignment,
    this.isRouteStart = false,
    this.isRouteEnd = false,
    required this.metadata,
    required this.servicePoint,
  }) : super(
            rowColor: metadata.nextStop == servicePoint ? SBBColors.royal.withOpacity(0.2) : Colors.transparent,
            kilometre: servicePoint.kilometre,
            isCurrentPosition: metadata.currentPosition == servicePoint);

  final Metadata metadata;
  final ServicePoint servicePoint;

  static const Alignment _defaultAlignment = Alignment.bottomCenter;

  final bool isRouteStart;
  final bool isRouteEnd;

  @override
  DASTableCell informationCell() {
    final servicePointName = servicePoint.name.localized;
    final textStyle = servicePoint.isHalt
        ? SBBTextStyles.largeLight.copyWith(fontSize: 24.0, fontStyle: FontStyle.italic)
        : SBBTextStyles.largeBold.copyWith(fontSize: 24.0);
    return DASTableCell(
      alignment: _defaultAlignment,
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
  DASTableCell iconsCell1() {
    return DASTableCell(
      padding: EdgeInsets.fromLTRB(sbbDefaultSpacing * 0.5, sbbDefaultSpacing * 0.5, 0, sbbDefaultSpacing * 0.5),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (servicePoint.bracketStation != null)
            BracketStationBody(
              bracketStation: servicePoint.bracketStation!,
              height: height!,
            ),
          if (!servicePoint.mandatoryStop)
            Align(
                alignment: Alignment.bottomLeft,
                child: SvgPicture.asset(
                  AppAssets.iconStopOnRequest,
                  key: stopOnRequestKey,
                ))
        ],
      ),
    );
  }

  @override
  DASTableCell routeCell() {
    return DASTableCell(
      padding: EdgeInsets.all(0.0),
      alignment: null,
      child: RouteCellBody(
        isStop: servicePoint.isStop,
        isCurrentPosition: isCurrentPosition,
        isRouteStart: isRouteStart,
        isRouteEnd: isRouteEnd,
        isStopOnRequest: !servicePoint.mandatoryStop,
      ),
    );
  }
}

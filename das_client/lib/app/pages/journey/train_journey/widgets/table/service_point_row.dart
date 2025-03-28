import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/graduated_speeds_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ServicePointRow extends BaseRowBuilder<ServicePoint> {
  static const Key stopOnRequestKey = Key('stopOnRequest');

  static const double rowHeight = 64.0;

  ServicePointRow({
    required super.metadata,
    required super.data,
    required BuildContext context,
    super.height = rowHeight,
    super.config,
    Color? rowColor,
  }) : super(
          rowColor: rowColor ??
              ((metadata.nextStop == data)
                  ? ThemeUtil.getColor(context, Color(0xFFCDD6E8), SBBColors.royal)
                  : ThemeUtil.getDASTableColor(context)),
          isSticky: true,
        );

  @override
  DASTableCell informationCell(BuildContext context) {
    final servicePointName = data.name.localized;
    return DASTableCell(
      alignment: defaultAlignment,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            servicePointName,
            style: data.isStation
                ? DASTextStyles.xLargeBold
                : DASTextStyles.xLargeLight.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  @override
  DASTableCell timeCell(BuildContext context) {
    return DASTableCell(child: Text('06:05:52'), alignment: defaultAlignment, color: specialCellColor);
  }

  @override
  DASTableCell iconsCell1(BuildContext context) {
    if (data.mandatoryStop) return DASTableCell.empty();

    return DASTableCell(
      alignment: Alignment.bottomCenter,
      child: SvgPicture.asset(
        AppAssets.iconStopOnRequest,
        key: stopOnRequestKey,
        colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
      ),
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
        isCurrentPosition: metadata.currentPosition == data,
        isRouteStart: metadata.routeStart == data,
        isRouteEnd: metadata.routeEnd == data,
        isStopOnRequest: !data.mandatoryStop,
        chevronAnimationData: config.chevronAnimationData,
      ),
    );
  }

  @override
  DASTableCell localSpeedCell(BuildContext context) {
    if (data.localSpeedData == null) return DASTableCell.empty();

    final currentTrainSeries = config.settings.selectedBreakSeries?.trainSeries ?? metadata.breakSeries?.trainSeries;
    final currentBreakSeries = config.settings.selectedBreakSeries?.breakSeries ?? metadata.breakSeries?.breakSeries;

    final graduatedSpeeds = data.localSpeedData!.speedsFor(currentTrainSeries, currentBreakSeries);
    if (graduatedSpeeds == null) return DASTableCell.empty();

    return DASTableCell(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: sbbDefaultSpacing * 0.5),
      child: GraduatedSpeedsCellBody(
        incomingSpeeds: graduatedSpeeds.incomingSpeeds,
        outgoingSpeeds: graduatedSpeeds.outgoingSpeeds,
      ),
    );
  }

  @override
  DASTableCell trackEquipment(BuildContext context) {
    if (config.trackEquipmentRenderData == null) {
      return DASTableCell.empty(color: specialCellColor);
    }

    return DASTableCell(
      color: specialCellColor,
      padding: const EdgeInsets.all(0.0),
      alignment: null,
      child: TrackEquipmentCellBody(
        renderData: config.trackEquipmentRenderData!,
      ),
    );
  }
}

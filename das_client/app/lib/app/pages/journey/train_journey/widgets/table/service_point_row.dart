import 'package:app/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_tab.dart';
import 'package:app/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_view_model.dart';
import 'package:app/app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/app/pages/journey/train_journey/widgets/table/cells/graduated_speeds_cell_body.dart';
import 'package:app/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:app/app/pages/journey/train_journey/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:app/app/widgets/assets.dart';
import 'package:app/app/widgets/das_text_styles.dart';
import 'package:app/app/widgets/stickyheader/sticky_level.dart';
import 'package:app/app/widgets/table/das_table_cell.dart';
import 'package:app/model/journey/service_point.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ServicePointRow extends CellRowBuilder<ServicePoint> {
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
                  ? ThemeUtil.getColor(context, Color(0xFFCDD6E8), SBBColors.royal150)
                  : ThemeUtil.getDASTableColor(context)),
          stickyLevel: StickyLevel.first,
        );

  @override
  DASTableCell informationCell(BuildContext context) {
    final servicePointName = data.name;
    return DASTableCell(
      onTap: () {
        final viewModel = context.read<DetailModalSheetViewModel>();
        viewModel.open(tab: DetailModalSheetTab.communication, servicePoint: data);
      },
      alignment: Alignment.bottomLeft,
      child: Text(
        servicePointName,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
        style:
            data.isStation ? DASTextStyles.xLargeBold : DASTextStyles.xLargeLight.copyWith(fontStyle: FontStyle.italic),
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

    final currentBreakSeries = config.settings.resolvedBreakSeries(metadata);

    final graduatedSpeeds =
        data.localSpeedData!.speedsFor(currentBreakSeries?.trainSeries, currentBreakSeries?.breakSeries);
    if (graduatedSpeeds == null) return DASTableCell.empty();

    final relevantGraduatedSpeedInfo = data.relevantGraduatedSpeedInfo(currentBreakSeries);

    return DASTableCell(
      onTap: () {
        final viewModel = context.read<DetailModalSheetViewModel>();
        viewModel.open(tab: DetailModalSheetTab.graduatedSpeeds, servicePoint: data);
      },
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: sbbDefaultSpacing * 0.5),
      child: GraduatedSpeedsCellBody(
        incomingSpeeds: graduatedSpeeds.incomingSpeeds,
        outgoingSpeeds: graduatedSpeeds.outgoingSpeeds,
        hasAdditionalInformation: relevantGraduatedSpeedInfo.isNotEmpty,
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

  @override
  DASTableCell gradientDownhillCell(BuildContext context) {
    return gradientCell(data.decisiveGradient?.downhill);
  }

  @override
  DASTableCell gradientUphillCell(BuildContext context) {
    return gradientCell(data.decisiveGradient?.uphill);
  }

  DASTableCell gradientCell(double? value) {
    if (value == null) {
      return DASTableCell.empty();
    }

    return DASTableCell(
        child: Text(
          value.round().toString(),
          style: DASTextStyles.largeRoman,
        ),
        alignment: defaultAlignment);
  }
}

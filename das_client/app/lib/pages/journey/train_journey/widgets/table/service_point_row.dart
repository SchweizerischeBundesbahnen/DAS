import 'package:app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_tab.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/arrival_departure_time/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/graduated_speeds_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/das_table_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class ServicePointRow extends CellRowBuilder<ServicePoint> {
  static const Key stopOnRequestKey = Key('stopOnRequest');
  static const Key timeCellInServicePointRowKey = Key('timeCellInServicePointRow');

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
                  ? ThemeUtil.getColor(context, Color(0x4D143A85), SBBColors.royal150)
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
    final times = data.arrivalDepartureTime;
    if (times == null) return DASTableCell.empty(color: specialCellColor);
    if (!times.hasAnyTime) return DASTableCell.empty(color: specialCellColor);

    final viewModel = context.read<ArrivalDepartureTimeViewModel>();

    return DASTableCell(
      onTap: () => viewModel.toggleCalculatedTime(),
      child: StreamBuilder(
          key: timeCellInServicePointRowKey,
          stream: viewModel.rxShowCalculatedTimes,
          initialData: viewModel.showCalculatedTimes,
          builder: (context, snapshot) {
            final showCalculatedTimes = snapshot.data ?? false;

            bool isTimeCalculated = false;
            DateTime? depTime;
            DateTime? arrTime;
            if (showCalculatedTimes) {
              if (times.hasAnyCalculatedTime) {
                // show calculated
                depTime = times.operationalDepartureTime;
                arrTime = times.operationalArrivalTime;
                isTimeCalculated = true;
              } else {
                // empty
              }
            } else {
              // show Planned
              depTime = times.plannedDepartureTime;
              arrTime = times.plannedArrivalTime;
            }

            String formattedDepTime = '';
            String formattedArrTime = '';

            if (depTime != null) formattedDepTime = Format.time(depTime, showSeconds: true);
            if (arrTime != null) formattedArrTime = Format.time(arrTime, showSeconds: true);

            int timeLength = 5; // noSeconds
            if (isTimeCalculated) {
              timeLength = 7;
            }

            formattedDepTime = formattedDepTime.substring(
                0, timeLength <= formattedDepTime.length ? timeLength : formattedDepTime.length);
            formattedArrTime = formattedArrTime.substring(
                0, timeLength <= formattedArrTime.length ? timeLength : formattedArrTime.length);

            if (formattedDepTime.isNotEmpty && !data.isStop) formattedDepTime = '($formattedDepTime)';
            if (formattedArrTime.isNotEmpty && !data.isStop) formattedArrTime = '($formattedArrTime)';

            final isArrTimeBold = formattedDepTime.isEmpty && !isTimeCalculated;

            return Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$formattedArrTime\n', style: isArrTimeBold ? DASTextStyles.largeBold : null),
                  TextSpan(text: formattedDepTime, style: DASTextStyles.largeBold)
                ],
              ),
            );
          }),
      alignment: defaultAlignment,
      color: specialCellColor,
    );
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

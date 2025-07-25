import 'package:app/extension/base_data_extension.dart';
import 'package:app/extension/station_sign_extension.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_tab.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/arrival_departure_time/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/advised_speed_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/speed_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/time_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/text_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/speed_display.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class ServicePointRow extends CellRowBuilder<ServicePoint> {
  static const Key stopOnRequestKey = Key('stopOnRequest');
  static const Key reducedSpeedKey = Key('reducedSpeed');

  static const double baseRowHeight = 64.0;
  static const double propertyRowHeight = 28.0;

  ServicePointRow({
    required super.metadata,
    required super.data,
    required BuildContext context,
    required super.rowIndex,
    super.config,
    Color? rowColor,
  }) : super(
         rowColor:
             rowColor ??
             ((metadata.nextStop == data)
                 ? ThemeUtil.getColor(context, Color(0xFFB1BED4), SBBColors.royal150)
                 : ThemeUtil.getDASTableColor(context)),
         stickyLevel: StickyLevel.first,
         height: calculateHeight(data, config.settings.resolvedBreakSeries(metadata)),
       );

  @override
  DASTableCell kilometreCell(BuildContext context) {
    return _wrapToBaseHeight(super.kilometreCell(context));
  }

  @override
  DASTableCell informationCell(BuildContext context) {
    final servicePointName = data.name;
    return DASTableCell(
      onTap: () {
        final viewModel = context.read<ServicePointModalViewModel>();
        viewModel.open(context, tab: ServicePointModalTab.communication, servicePoint: data);
      },
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            servicePointName,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: data.isStation
                ? DASTextStyles.xLargeBold
                : DASTextStyles.xLargeLight.copyWith(fontStyle: FontStyle.italic),
          ),
          ..._stationProperties(context),
        ],
      ),
    );
  }

  List<Widget> _stationProperties(BuildContext context) {
    final currentBreakSeries = config.settings.resolvedBreakSeries(metadata);
    final properties = data.propertiesFor(currentBreakSeries);
    if (properties.isEmpty) return [];

    return properties.map((property) {
      final speed = property.speeds?.speedFor(
        currentBreakSeries?.trainSeries,
        breakSeries: currentBreakSeries?.breakSeries,
      );

      return Padding(
        padding: EdgeInsets.only(top: 4),
        child: SizedBox(
          height: propertyRowHeight - 4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: sbbDefaultSpacing * 0.25,
            children: [
              if (property.sign != null) _icon(context, property.sign!.iconAsset(), Key(property.sign!.name)),
              if (property.text != null)
                Text.rich(
                  TextUtil.parseHtmlText(
                    property.text!,
                    DASTextStyles.mediumRoman,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              if (speed != null && speed.reduced) _icon(context, AppAssets.iconReducedSpeed, reducedSpeedKey),
              /*if (speed != null)
                SpeedCellBody(
                  speed: speed.speed,
                  rowIndex: rowIndex,
                  singleLine: true,
                ),*/
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  DASTableCell timeCell(BuildContext context) {
    final times = data.arrivalDepartureTime;
    final viewModel = context.read<ArrivalDepartureTimeViewModel>();

    if (times == null || !times.hasAnyTime) {
      return DASTableCell.empty(color: specialCellColor, onTap: () => viewModel.toggleOperationalTime());
    }

    return _wrapToBaseHeight(
      DASTableCell(
        onTap: () => viewModel.toggleOperationalTime(),
        child: TimeCellBody(times: times, viewModel: viewModel, showTimesInBrackets: !data.isStop),
        alignment: defaultAlignment,
        color: specialCellColor,
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
        chevronPosition: data.chevronPosition,
      ),
    );
  }

  @override
  DASTableCell iconsCell1(BuildContext context) {
    if (data.mandatoryStop && data.stationSign1 == null && data.stationSign2 == null) return DASTableCell.empty();

    return _wrapToBaseHeight(
      DASTableCell(
        alignment: Alignment.bottomRight,
        padding: EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.5, horizontal: 2),
        child: Padding(
          padding: config.bracketStationRenderData != null ? const EdgeInsets.only(right: 24.0) : EdgeInsets.zero,
          child: Wrap(
            spacing: 2,
            children: [
              if (!data.mandatoryStop) _icon(context, AppAssets.iconStopOnRequest, stopOnRequestKey),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  if (data.stationSign2 != null)
                    _icon(context, data.stationSign2!.iconAsset(), Key(data.stationSign2!.name)),
                  if (data.stationSign1 != null)
                    _icon(context, data.stationSign1!.iconAsset(), Key(data.stationSign1!.name)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon(BuildContext context, String assetName, Key key) {
    return SvgPicture.asset(
      assetName,
      key: key,
      colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
    );
  }

  @override
  DASTableCell localSpeedCell(BuildContext context) {
    if (data.localSpeeds == null) return DASTableCell.empty();

    final currentBreakSeries = config.settings.resolvedBreakSeries(metadata);

    final trainSeriesSpeed = data.localSpeeds!.speedFor(
      currentBreakSeries?.trainSeries,
      breakSeries: currentBreakSeries?.breakSeries,
    );
    if (trainSeriesSpeed == null) return DASTableCell.empty();

    final relevantGraduatedSpeedInfo = data.relevantGraduatedSpeedInfo(currentBreakSeries);

    return DASTableCell(
      onTap: relevantGraduatedSpeedInfo.isNotEmpty ? () => _openGraduatedSpeedDetails(context) : null,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: sbbDefaultSpacing * 0.5),
      child: SpeedDisplay(
        speed: trainSeriesSpeed.speed,
        hasAdditionalInformation: relevantGraduatedSpeedInfo.isNotEmpty,
      ),
    );
  }

  @override
  DASTableCell advisedSpeedCell(BuildContext context) {
    final currentBreakSeries = config.settings.resolvedBreakSeries(metadata);
    final trainSeriesSpeed = data.speeds?.speedFor(
      currentBreakSeries?.trainSeries,
      breakSeries: currentBreakSeries?.breakSeries,
    );

    return DASTableCell(
      child: AdvisedSpeedCellBody(
        calculatedSpeed: data.calculatedSpeed,
        lineSpeed: trainSeriesSpeed?.speed as SingleSpeed?,
        rowIndex: rowIndex,
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
        position:
            data.chevronPosition +
            RouteCellBody.chevronHeight +
            (data.isStop ? RouteCellBody.routeCircleSize / 2 : 0.0),
      ),
    );
  }

  @override
  DASTableCell gradientDownhillCell(BuildContext context) {
    return _wrapToBaseHeight(gradientCell(data.decisiveGradient?.downhill));
  }

  @override
  DASTableCell gradientUphillCell(BuildContext context) {
    return _wrapToBaseHeight(gradientCell(data.decisiveGradient?.uphill));
  }

  DASTableCell gradientCell(double? value) {
    if (value == null) {
      return DASTableCell.empty(color: specialCellColor);
    }

    return DASTableCell(
      color: specialCellColor,
      child: Text(
        value.round().toString(),
        style: DASTextStyles.largeRoman,
      ),
      alignment: defaultAlignment,
    );
  }

  void _openGraduatedSpeedDetails(BuildContext context) {
    final viewModel = context.read<ServicePointModalViewModel>();
    viewModel.open(context, tab: ServicePointModalTab.graduatedSpeeds, servicePoint: data);
  }

  DASTableCell _wrapToBaseHeight(DASTableCell cell, [double verticalPadding = 8.0]) {
    return DASTableCell(
      border: cell.border,
      onTap: cell.onTap,
      color: cell.color,
      padding: cell.padding,
      alignment: Alignment.topLeft,
      clipBehaviour: cell.clipBehaviour,
      child: SizedBox(
        height: baseRowHeight - verticalPadding * 2,
        child: Align(alignment: cell.alignment ?? defaultAlignment, child: cell.child),
      ),
    );
  }

  @override
  ShowSpeedBehavior get showSpeedBehavior => ShowSpeedBehavior.alwaysOrPreviousOnStickiness;

  static double calculateHeight(ServicePoint data, BreakSeries? currentBreakSeries) {
    final properties = data.propertiesFor(currentBreakSeries);

    if (properties.isEmpty) return baseRowHeight;
    return baseRowHeight + (properties.length * propertyRowHeight);
  }
}

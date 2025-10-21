import 'package:app/extension/station_sign_extension.dart';
import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_tab.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/arrival_departure_time/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/show_speed_behaviour.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/time_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/text_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:app/widgets/speed_display.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/das_table_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class ServicePointRow extends CellRowBuilder<ServicePoint> {
  static const Key stopOnRequestKey = Key('stopOnRequest');
  static const Key reducedSpeedKey = Key('reducedSpeed');

  static const double baseRowHeight = 64.0;
  static const double propertyRowHeight = 28.0;

  static double calculateHeight(ServicePoint data, BreakSeries? currentBreakSeries) {
    final properties = data.propertiesFor(currentBreakSeries);

    if (properties.isEmpty) return baseRowHeight;
    return baseRowHeight + (properties.length * propertyRowHeight);
  }

  static Color _resolveRowColor(BuildContext context, JourneyPositionModel? position, ServicePoint data) {
    if (position?.nextStop == data) return SBBColors.night;
    return data.isAdditional ? ThemeUtil.getBackgroundColor(context) : ThemeUtil.getDASTableColor(context);
  }

  ServicePointRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.journeyPosition,
    required BuildContext context,
    this.highlightNextStop = true,
    super.config,
    super.key,
    Color? rowColor,
  }) : super(
         rowColor: rowColor ?? _resolveRowColor(context, journeyPosition, data),
         stickyLevel: StickyLevel.first,
         height: calculateHeight(data, config.settings.resolvedBreakSeries(metadata)),
       );

  final bool highlightNextStop;

  @override
  DASTableCell kilometreCell(BuildContext context) {
    return _wrapToBaseHeight(super.kilometreCell(context));
  }

  @override
  DASTableCell informationCell(BuildContext context) {
    final servicePointName = data.betweenBrackets ? '(${data.name})' : data.name;
    final color = _isNextStop && highlightNextStop ? SBBColors.white : null;
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
                ? DASTextStyles.xLargeBold.copyWith(color: color)
                : DASTextStyles.xLargeLight.copyWith(fontStyle: FontStyle.italic, color: color),
          ),
          ..._stationProperties(context),
        ],
      ),
    );
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
        child: TimeCellBody(
          times: times,
          viewModel: viewModel,
          showTimesInBrackets: !data.isStop,
          fontColor: _isNextStop && specialCellColor == null ? Colors.white : null,
        ),
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
        isCurrentPosition: isCurrentPosition,
        isRouteStart: metadata.journeyStart == data,
        isRouteEnd: metadata.journeyEnd == data,
        isStopOnRequest: !data.mandatoryStop,
        chevronAnimationData: config.chevronAnimationData,
        chevronPosition: chevronPosition,
        routeColor: _isNextStop && specialCellColor == null ? Colors.white : null,
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

  @override
  DASTableCell localSpeedCell(BuildContext context) {
    final currentBreakSeries = config.settings.resolvedBreakSeries(metadata);
    final relevantGraduatedSpeedInfo = data.relevantGraduatedSpeedInfo(currentBreakSeries);

    if (data.localSpeeds == null && relevantGraduatedSpeedInfo.isEmpty) return DASTableCell.empty();

    final trainSeriesSpeed = data.localSpeeds?.speedFor(
      currentBreakSeries?.trainSeries,
      breakSeries: currentBreakSeries?.breakSeries,
    );
    if (trainSeriesSpeed == null && relevantGraduatedSpeedInfo.isEmpty) return DASTableCell.empty();

    Widget child = Padding(
      padding: EdgeInsets.only(top: sbbDefaultSpacing * .5, right: sbbDefaultSpacing * .25),
      child: DotIndicator(
        child: SizedBox.expand(),
      ),
    );
    if (trainSeriesSpeed != null) {
      child = SpeedDisplay(
        speed: trainSeriesSpeed.speed,
        hasAdditionalInformation: relevantGraduatedSpeedInfo.isNotEmpty,
        isNextStop: _isNextStop,
      );
    }

    return DASTableCell(
      onTap: relevantGraduatedSpeedInfo.isNotEmpty ? () => _openGraduatedSpeedDetails(context) : null,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: sbbDefaultSpacing * 0.5),
      child: child,
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
        position: RouteCellBody.routeCirclePosition + (data.isStop ? RouteCellBody.routeCircleSize * 0.5 : 0.0),
        lineColor: _isNextStop && specialCellColor == null ? SBBColors.white : null,
      ),
    );
  }

  @override
  DASTableCell gradientDownhillCell(BuildContext context) {
    return _wrapToBaseHeight(_gradientCell(context, data.decisiveGradient?.downhill));
  }

  @override
  DASTableCell gradientUphillCell(BuildContext context) {
    return _wrapToBaseHeight(_gradientCell(context, data.decisiveGradient?.uphill));
  }

  @override
  ShowSpeedBehavior get showSpeedBehavior => ShowSpeedBehavior.alwaysOrPreviousOnStickiness;

  DASTableCell _gradientCell(BuildContext context, double? value) {
    if (value == null) {
      return DASTableCell.empty(color: specialCellColor);
    }

    final textColor = _isNextStop && specialCellColor == null ? SBBColors.white : null;
    final defaultTextStyle = DASTableTheme.of(context)?.data.dataTextStyle ?? DASTextStyles.largeRoman;
    return DASTableCell(
      color: specialCellColor,
      child: Text(
        value.round().toString(),
        style: defaultTextStyle.copyWith(color: textColor),
      ),
      alignment: defaultAlignment,
    );
  }

  void _openGraduatedSpeedDetails(BuildContext context) {
    final viewModel = context.read<ServicePointModalViewModel>();
    viewModel.open(context, tab: ServicePointModalTab.graduatedSpeeds, servicePoint: data);
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
                    _isNextStop && highlightNextStop
                        ? DASTextStyles.mediumRoman.copyWith(color: SBBColors.white)
                        : DASTextStyles.mediumRoman,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              if (speed != null && speed.reduced) _icon(context, AppAssets.iconReducedSpeed, reducedSpeedKey),
              if (speed != null)
                SpeedDisplay(
                  speed: speed.speed,
                  singleLine: true,
                  isNextStop: _isNextStop,
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _icon(BuildContext context, String assetName, Key key) {
    return SvgPicture.asset(
      assetName,
      key: key,
      colorFilter: ColorFilter.mode(
        _isNextStop ? SBBColors.white : ThemeUtil.getIconColor(context),
        BlendMode.srcIn,
      ),
    );
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

  bool get _isNextStop => journeyPosition?.nextStop == data;
}

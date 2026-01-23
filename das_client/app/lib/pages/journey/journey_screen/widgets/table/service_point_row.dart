import 'dart:math';

import 'package:app/extension/station_sign_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_advancement_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_cell_body.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/show_speed_behaviour.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/time_cell_body.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/animation.dart';
import 'package:app/util/text_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:app/widgets/speed_display.dart';
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

  static Color _resolveRowColor(BuildContext context, JourneyPositionModel position, ServicePoint data) {
    if (position.nextStop == data) return SBBColors.night;
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
         stickyLevel: .first,
         height: calculateHeight(data, config.settings.resolvedBreakSeries(metadata)),
         onStartToEndDragReached: journeyPosition.currentPosition != data
             ? () {
                 context.read<JourneyPositionViewModel>().setManualPosition(data);
                 context.read<JourneyTableAdvancementViewModel>().setAdvancementModeToManual();
               }
             : null,
         draggableBackgroundBuilder: (context, dragReached) {
           return DecoratedBox(
             decoration: BoxDecoration(color: SBBColors.granite),
             child: Padding(
               padding: const .only(left: SBBSpacing.medium),
               child: Align(
                 alignment: .centerLeft,
                 child: AnimatedSwitcher(
                   duration: DASAnimation.mediumDuration,
                   transitionBuilder: (child, animation) {
                     final centerLeftTween = AlignmentTween(begin: .centerLeft, end: .centerLeft);
                     return AlignTransition(
                       alignment: centerLeftTween.animate(animation),
                       child: ScaleTransition(scale: animation, child: child),
                     );
                   },
                   child: Text(
                     context.l10n.w_service_point_row_background_label,
                     key: ValueKey(dragReached),
                     style: DASTextStyles.largeRoman.copyWith(color: SBBColors.white),
                   ),
                 ),
               ),
             ),
           );
         },
       );

  final bool highlightNextStop;

  @override
  DASTableCell kilometreCell(BuildContext context) {
    return _wrapToBaseHeight(super.kilometreCell(context));
  }

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      onTap: () {
        if (shouldOpenDetailModalOnTap) {
          final viewModel = context.read<ServicePointModalViewModel>();
          viewModel.open(context, tab: .communication, servicePoint: data);
        }
      },
      alignment: .bottomLeft,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          _informationCellTitle(context),
          ..._stationProperties(context),
        ],
      ),
    );
  }

  bool get shouldOpenDetailModalOnTap => true;

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
      padding: .all(0.0),
      alignment: null,
      clipBehavior: .none,
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
        alignment: .bottomRight,
        padding: .symmetric(vertical: SBBSpacing.xSmall, horizontal: 2),
        child: Padding(
          padding: config.bracketStationRenderData != null ? const .only(right: SBBSpacing.large) : .zero,
          child: Wrap(
            spacing: 2,
            children: [
              if (!data.mandatoryStop) _icon(context, AppAssets.iconStopOnRequest, stopOnRequestKey),
              Row(
                mainAxisSize: .min,
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
      padding: .only(top: SBBSpacing.xSmall, right: SBBSpacing.xxSmall),
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
      alignment: .center,
      padding: .symmetric(vertical: 2.0, horizontal: SBBSpacing.xSmall),
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
      padding: const .all(0.0),
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
  ShowSpeedBehavior get showSpeedBehavior => .alwaysOrPreviousOnStickiness;

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
    viewModel.open(context, tab: .graduatedSpeeds, servicePoint: data);
  }

  Stream<bool> isModalOpenStream(BuildContext context) => context.read<DetailModalViewModel>().isModalOpen;

  bool isModalOpenValue(BuildContext context) => context.read<DetailModalViewModel>().isModalOpenValue;

  Widget _informationCellTitle(BuildContext context) {
    return StreamBuilder<bool>(
      stream: isModalOpenStream(context),
      initialData: isModalOpenValue(context),
      builder: (context, asyncSnapshot) {
        final isModalOpen = asyncSnapshot.requireData;
        final servicePointName = data.betweenBrackets ? '(${data.name})' : data.name;
        final color = _isNextStop && highlightNextStop ? SBBColors.white : null;
        return DefaultTextStyle.merge(
          style: data.isStation
              ? DASTextStyles.xLargeBold.copyWith(color: color)
              : DASTextStyles.xLargeLight.copyWith(fontStyle: FontStyle.italic, color: color),
          child: AnimatedSwitcher(
            duration: DASAnimation.longDuration,
            child: Row(
              mainAxisAlignment: isModalOpen ? .spaceBetween : .start,
              children: [
                Flexible(
                  child: Text(
                    servicePointName,
                    textAlign: TextAlign.start,
                    overflow: .ellipsis,
                  ),
                ),
                if (data.trackGroup != null) ...[
                  if (!isModalOpen) SizedBox(width: SBBSpacing.medium),
                  Text(data.trackGroup!),
                ],
              ],
            ),
          ),
        );
      },
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
        padding: .only(top: 4),
        child: SizedBox(
          height: propertyRowHeight - 4,
          child: Row(
            mainAxisSize: .min,
            crossAxisAlignment: .center,
            spacing: SBBSpacing.xxSmall,
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
                  overflow: .ellipsis,
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
      alignment: .topLeft,
      clipBehavior: cell.clipBehavior,
      child: SizedBox(
        height: baseRowHeight - verticalPadding * 2,
        child: Align(alignment: cell.alignment ?? defaultAlignment, child: cell.child),
      ),
    );
  }

  bool get _isNextStop => journeyPosition.nextStop == data;
}

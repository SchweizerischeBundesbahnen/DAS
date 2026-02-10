import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/communication_network_icon.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/additional_speed_restriction_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/advised_speed_cell_body.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/bracket_station_cell_body.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/calculated_speed_cell_body.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/line_speed_cell_body.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_cell_body.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_chevron.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/show_speed_behaviour.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/column_definition.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/config/journey_config.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/service_point_row.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/modification_indicator.dart';
import 'package:app/widgets/speed_display.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/das_table_theme.dart';
import 'package:app/widgets/table/row/das_table_row.dart';
import 'package:app/widgets/table/row/das_table_row_builder.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class CellRowBuilder<T extends JourneyPoint> extends DASTableRowBuilder<T> {
  static const double rowHeight = 44.0;

  CellRowBuilder({
    required this.metadata,
    required super.data,
    required super.rowIndex,
    required this.journeyPosition,
    super.height = rowHeight,
    super.stickyLevel,
    super.key,
    super.decoration,
    this.config = const JourneyConfig(),
    this.defaultAlignment = .bottomCenter,
    this.onTap,
    this.onStartToEndDragReached,
    this.draggableBackgroundBuilder,
    this.isGrouped = false,
  });

  final Alignment defaultAlignment;
  final Metadata metadata;
  final JourneyPositionModel journeyPosition;
  final JourneyConfig config;
  final VoidCallback? onTap;
  final VoidCallback? onStartToEndDragReached;
  final Widget Function(BuildContext, bool)? draggableBackgroundBuilder;
  final bool isGrouped;

  @override
  DASTableRow build(BuildContext context) {
    return DASTableCellRow(
      key: key,
      height: height,
      decoration: decoration,
      onTap: onTap,
      onStartToEndDragReached: onStartToEndDragReached,
      draggableBackgroundBuilder: draggableBackgroundBuilder,
      stickyLevel: stickyLevel,
      rowIndex: rowIndex,
      cells: {
        ColumnDefinition.kilometre.index: kilometreCell(context),
        ColumnDefinition.time.index: timeCell(context),
        ColumnDefinition.route.index: routeCell(context),
        ColumnDefinition.trackEquipment.index: trackEquipment(context),
        ColumnDefinition.icons1.index: iconsCell1(context),
        ColumnDefinition.bracketStation.index: bracketStation(context),
        ColumnDefinition.informationCell.index: informationCell(context),
        ColumnDefinition.icons2.index: iconsCell2(context),
        ColumnDefinition.icons3.index: iconsCell3(context),
        ColumnDefinition.localSpeed.index: localSpeedCell(context),
        ColumnDefinition.brakedWeightSpeed.index: brakedWeightSpeedCell(context),
        ColumnDefinition.advisedSpeed.index: advisedSpeedCell(context),
        ColumnDefinition.communicationNetwork.index: communicationNetworkCell(context),
        ColumnDefinition.gradientUphill.index: gradientUphillCell(context),
        ColumnDefinition.gradientDownhill.index: gradientDownhillCell(context),
      },
      markAsDeleted: data.isDeleted,
    );
  }

  DASTableCell kilometreCell(BuildContext context) {
    Border? leftBorder;
    if (_isWithinShortTermChange) {
      leftBorder = Border(
        left: BorderSide(
          width: SBBSpacing.xxSmall,
          color: ThemeUtil.getColor(context, SBBColors.turquoise, SBBColors.turquoiseDark),
        ),
      );
    }

    if (data.kilometre.isEmpty) {
      return DASTableCell.empty(
        decoration: DASTableCellDecoration(
          border: leftBorder,
          color: specialCellColor,
        ),
      );
    }

    final textColor = _isNextStop && specialCellColor == null ? SBBColors.white : null;
    final defaultTextStyle = DASTableTheme.of(context)?.data.dataTextStyle;
    final textStyle = (defaultTextStyle ?? sbbTextStyle.romanStyle.large).copyWith(color: textColor);
    return DASTableCell(
      decoration: DASTableCellDecoration(color: specialCellColor, border: leftBorder),
      child: ModificationIndicator(
        show: data.hasModificationUpdated,
        offset: Offset(0, -SBBSpacing.small),
        child: Column(
          mainAxisAlignment: .end,
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          children: [
            Text(data.kilometre[0].toStringAsFixed(1), style: textStyle),
            if (data.kilometre.length > 1) Text(data.kilometre[1].toStringAsFixed(1), style: textStyle),
          ],
        ),
      ),
      alignment: .bottomLeft,
    );
  }

  DASTableCell routeCell(BuildContext context) {
    return DASTableCell(
      decoration: DASTableCellDecoration(color: specialCellColor),
      padding: .all(0.0),
      alignment: null,
      clipBehavior: .none,
      child: RouteCellBody(
        isCurrentPosition: isCurrentPosition,
        isRouteStart: metadata.journeyStart == data,
        isRouteEnd: metadata.journeyEnd == data,
        chevronAnimationData: config.chevronAnimationData,
        chevronPosition: chevronPosition,
      ),
    );
  }

  bool get isCurrentPosition => journeyPosition.currentPosition == data;

  DASTableCell trackEquipment(BuildContext context) {
    if (config.trackEquipmentRenderData == null) {
      return DASTableCell.empty(decoration: DASTableCellDecoration(color: specialCellColor));
    }

    return DASTableCell(
      decoration: DASTableCellDecoration(color: specialCellColor),
      padding: .all(0.0),
      alignment: null,
      child: TrackEquipmentCellBody(
        renderData: config.trackEquipmentRenderData!,
        lineColor: _isNextStop && specialCellColor == null ? SBBColors.white : null,
      ),
    );
  }

  DASTableCell localSpeedCell(BuildContext context) {
    return speedCell(data.localSpeeds);
  }

  DASTableCell brakedWeightSpeedCell(BuildContext context) {
    final inEtcsLevel2Segment = metadata.nonStandardTrackEquipmentSegments.isInEtcsLevel2Segment(data.order);
    if (inEtcsLevel2Segment && data.dataType != .cabSignaling) {
      return DASTableCell.empty();
    }
    return DASTableCell(
      alignment: .center,
      padding: .symmetric(vertical: 2.0, horizontal: SBBSpacing.xSmall),
      child: LineSpeedCellBody(
        order: data.order,
        showSpeedBehavior: showSpeedBehavior,
        isNextStop: _isNextStop,
      ),
    );
  }

  DASTableCell speedCell(List<TrainSeriesSpeed>? speedData) {
    final selectedBreakSeries = config.settings.resolvedBreakSeries(metadata);
    final trainSeriesSpeed = speedData.speedFor(
      selectedBreakSeries?.trainSeries,
      breakSeries: selectedBreakSeries?.breakSeries,
    );

    return DASTableCell(
      alignment: .center,
      padding: .symmetric(vertical: 2.0, horizontal: SBBSpacing.xSmall),
      child: SpeedDisplay(
        speed: trainSeriesSpeed?.speed,
        isNextStop: _isNextStop,
      ),
    );
  }

  DASTableCell bracketStation(BuildContext context) {
    final bracketStationRenderData = config.bracketStationRenderData;
    if (bracketStationRenderData == null) return DASTableCell.empty();

    return DASTableCell(
      padding: .all(0.0),
      clipBehavior: .none,
      child: BracketStationCellBody(
        stationAbbreviation: config.bracketStationRenderData!.isStart
            ? bracketStationRenderData.stationAbbreviation
            : null,
        height: height,
      ),
    );
  }

  DASTableCell communicationNetworkCell(BuildContext context) {
    final networkChange = metadata.communicationNetworkChanges.changeAtOrder(data.order);
    if (networkChange == null) return DASTableCell.empty();

    return DASTableCell(
      alignment: .bottomCenter,
      child: CommunicationNetworkIcon(networkType: networkChange),
    );
  }

  DASTableCell timeCell(BuildContext context) =>
      DASTableCell.empty(decoration: DASTableCellDecoration(color: specialCellColor));

  DASTableCell informationCell(BuildContext context) => DASTableCell.empty();

  DASTableCell advisedSpeedCell(BuildContext context) {
    Border? rightBorder;
    if (_isWithinShortTermChange) {
      rightBorder = Border(
        right: BorderSide(
          width: SBBSpacing.xxSmall,
          color: ThemeUtil.getColor(context, SBBColors.turquoise, SBBColors.turquoiseDark),
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      );
    }

    final advisedSpeedsSegment = metadata.advisedSpeedSegments.appliesToOrder(data.order);
    final isLastAdvisedSpeed = advisedSpeedsSegment.firstOrNull?.endData == data;
    final showAdvisedSpeed =
        advisedSpeedsSegment.isNotEmpty &&
        journeyPosition.currentPosition != null &&
        advisedSpeedsSegment.first.appliesToOrder(journeyPosition.currentPosition!.order);

    if (showAdvisedSpeed && !isLastAdvisedSpeed) {
      final isFirst = advisedSpeedsSegment.first.startOrder == data.order;

      return DASTableCell(
        padding: .all(0.0),
        decoration: DASTableCellDecoration(border: rightBorder),
        clipBehavior: .none,
        child: AdvisedSpeedCellBody(
          metadata: metadata,
          order: data.order,
          showSpeedBehavior: isFirst ? .always : showSpeedBehavior,
        ),
      );
    }

    return DASTableCell(
      decoration: DASTableCellDecoration(border: rightBorder),
      child: CalculatedSpeedCellBody(
        order: data.order,
        showSpeedBehavior: showAdvisedSpeed && isLastAdvisedSpeed ? .alwaysOrPrevious : showSpeedBehavior,
        isNextStop: _isNextStop,
      ),
    );
  }

  DASTableCell iconsCell1(BuildContext context) => DASTableCell.empty();

  DASTableCell iconsCell2(BuildContext context) => DASTableCell.empty();

  DASTableCell iconsCell3(BuildContext context) => DASTableCell.empty();

  DASTableCell gradientUphillCell(BuildContext context) =>
      DASTableCell.empty(decoration: DASTableCellDecoration(color: specialCellColor));

  DASTableCell gradientDownhillCell(BuildContext context) =>
      DASTableCell.empty(decoration: DASTableCellDecoration(color: specialCellColor));

  Color? get specialCellColor =>
      getAdditionalSpeedRestriction() != null ? AdditionalSpeedRestrictionRow.additionalSpeedRestrictionColor : null;

  AdditionalSpeedRestriction? getAdditionalSpeedRestriction() {
    return metadata.additionalSpeedRestrictions
        .where(
          (it) =>
              it.orderFrom <= data.order &&
              it.orderTo >= data.order &&
              it.isDisplayed(metadata.nonStandardTrackEquipmentSegments),
        )
        .firstOrNull;
  }

  ShowSpeedBehavior get showSpeedBehavior => .never;

  bool get _isNextStop => journeyPosition.nextStop == data;

  static double rowHeightForData(BaseData data, BreakSeries? currentBreakSeries) {
    return switch (data.dataType) {
      .servicePoint => ServicePointRow.calculateHeight(data as ServicePoint, currentBreakSeries),
      _ => CellRowBuilder.rowHeight,
    };
  }

  double get chevronPosition => CellRowBuilder.calculateChevronPosition(data, height);

  bool get _isWithinShortTermChange => metadata.shortTermChanges.appliesToOrder(data.order).isNotEmpty;

  static double calculateChevronPosition(BaseData data, double height) {
    switch (data.dataType) {
      case .servicePoint:
        final servicePoint = data as ServicePoint;
        if (servicePoint.isStop) {
          return RouteCellBody.routeCirclePosition - RouteChevron.chevronHeight;
        } else {
          return RouteCellBody.routeCirclePosition + RouteChevron.chevronHeight;
        }
      case .baliseLevelCrossingGroup:
        return height * 0.5;
      default:
        // additional -1.5 because line overdraws a bit from rotation
        return height - RouteChevron.chevronHeight - 1.5;
    }
  }
}

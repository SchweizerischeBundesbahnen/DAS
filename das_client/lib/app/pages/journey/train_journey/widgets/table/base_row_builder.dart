import 'dart:math';

import 'package:das_client/app/pages/journey/train_journey/widgets/table/additional_speed_restriction_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/bracket_station_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/graduated_speeds_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/train_journey_config.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/model/journey/additional_speed_restriction.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/speed_data.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BaseRowBuilder<T extends BaseData> extends DASTableRowBuilder {
  static const double rowHeight = 44.0;

  const BaseRowBuilder({
    required this.metadata,
    required this.data,
    super.height = rowHeight,
    this.config = const TrainJourneyConfig(),
    this.defaultAlignment = Alignment.bottomCenter,
    this.rowColor,
    this.onTap,
    this.isGrouped = false,
    this.isSticky = false,
  });

  final Alignment defaultAlignment;
  final Color? rowColor;
  final Metadata metadata;
  final T data;
  final TrainJourneyConfig config;
  final VoidCallback? onTap;
  final bool isGrouped;
  final bool isSticky;

  @override
  DASTableRow build(BuildContext context) {
    return DASTableRow(
      height: height,
      color: rowColor,
      onTap: onTap,
      isSticky: isSticky,
      cells: [
        kilometreCell(context),
        timeCell(context),
        routeCell(context),
        trackEquipment(context),
        iconsCell1(context),
        bracketStation(context),
        informationCell(context),
        iconsCell2(context),
        iconsCell3(context),
        localSpeedCell(context),
        brakedWeightSpeedCell(context),
        advisedSpeedCell(context),
        actionsCell(context),
      ],
    );
  }

  DASTableCell kilometreCell(BuildContext context) {
    if (data.kilometre.isEmpty) {
      return DASTableCell.empty(color: specialCellColor);
    }

    return DASTableCell(
      color: specialCellColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.kilometre[0].toStringAsFixed(1)),
          if (data.kilometre.length > 1) Text(data.kilometre[1].toStringAsFixed(1))
        ],
      ),
      alignment: Alignment.centerLeft,
    );
  }

  DASTableCell routeCell(BuildContext context) {
    return DASTableCell(
      color: specialCellColor,
      padding: EdgeInsets.all(0.0),
      alignment: null,
      clipBehaviour: Clip.none,
      child: RouteCellBody(
        metadata: metadata,
        isCurrentPosition: metadata.currentPosition == data,
        isRouteStart: metadata.routeStart == data,
        isRouteEnd: metadata.routeEnd == data,
        chevronAnimationData: config.chevronAnimationData,
      ),
    );
  }

  DASTableCell trackEquipment(BuildContext context) {
    if (config.trackEquipmentRenderData == null) {
      return DASTableCell.empty(color: specialCellColor);
    }

    return DASTableCell(
      color: specialCellColor,
      padding: EdgeInsets.all(0.0),
      alignment: null,
      child: TrackEquipmentCellBody(
        renderData: config.trackEquipmentRenderData!,
      ),
    );
  }

  DASTableCell timeCell(BuildContext context) {
    return DASTableCell.empty(color: specialCellColor);
  }

  DASTableCell informationCell(BuildContext context) {
    return DASTableCell.empty();
  }

  DASTableCell localSpeedCell(BuildContext context) {
    return speedCell(data.localSpeedData, DASTableCell.empty());
  }

  DASTableCell advisedSpeedCell(BuildContext context) {
    return DASTableCell.empty();
  }

  DASTableCell brakedWeightSpeedCell(BuildContext context) {
    return speedCell(data.speedData, DASTableCell(child: Text('XX'), alignment: Alignment.center));
  }

  DASTableCell speedCell(SpeedData? speedData, DASTableCell defaultCell) {
    if (speedData == null) {
      return DASTableCell.empty();
    }

    final currentTrainSeries = config.settings.selectedBreakSeries?.trainSeries ?? metadata.breakSeries?.trainSeries;
    final currentBreakSeries = config.settings.selectedBreakSeries?.breakSeries ?? metadata.breakSeries?.breakSeries;

    final graduatedSpeeds = speedData.speedsFor(currentTrainSeries, currentBreakSeries);
    if (graduatedSpeeds == null) {
      return defaultCell;
    }

    return DASTableCell(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: sbbDefaultSpacing * 0.5),
      child: GraduatedSpeedsCellBody(
        incomingSpeeds: graduatedSpeeds.incomingSpeeds,
        outgoingSpeeds: graduatedSpeeds.outgoingSpeeds,
      ),
    );
  }

  DASTableCell iconsCell1(BuildContext context) {
    return DASTableCell.empty();
  }

  DASTableCell bracketStation(BuildContext context) {
    final bracketStationRenderData = config.bracketStationRenderData;
    if (bracketStationRenderData == null) return DASTableCell.empty();

    return DASTableCell(
      padding: EdgeInsets.all(0.0),
      clipBehaviour: Clip.none,
      child: BracketStationCellBody(
        stationAbbreviation:
            config.bracketStationRenderData!.isStart ? bracketStationRenderData.stationAbbreviation : null,
        height: height,
      ),
    );
  }

  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell.empty();
  }

  DASTableCell iconsCell3(BuildContext context) {
    return DASTableCell.empty();
  }

  DASTableCell actionsCell(BuildContext context) {
    return DASTableCell.empty();
  }

  Color? get specialCellColor =>
      getAdditionalSpeedRestriction() != null ? AdditionalSpeedRestrictionRow.additionalSpeedRestrictionColor : null;

  AdditionalSpeedRestriction? getAdditionalSpeedRestriction() {
    return metadata.additionalSpeedRestrictions
        .where((it) => it.orderFrom <= data.order && it.orderTo >= data.order)
        .firstOrNull;
  }

  static double rowHeightForData(BaseData data) {
    switch (data.type) {
      case Datatype.servicePoint:
        return ServicePointRow.rowHeight;
      default:
        return BaseRowBuilder.rowHeight;
    }
  }
}

import 'package:das_client/app/pages/journey/train_journey/widgets/table/additional_speed_restriction_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/bracket_station_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/render_data/train_journey_render_data.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/model/journey/additional_speed_restriction.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:flutter/material.dart';

class BaseRowBuilder<T extends BaseData> extends DASTableRowBuilder {
  static const double rowHeight = 44.0;

  const BaseRowBuilder({
    required this.metadata,
    required this.data,
    super.height = rowHeight,
    this.renderData = const TrainJourneyRenderData(),
    this.defaultAlignment = Alignment.bottomCenter,
    this.rowColor,
    this.onTap,
    this.isGrouped = false,
  });

  final Alignment defaultAlignment;
  final Color? rowColor;
  final Metadata metadata;
  final T data;
  final TrainJourneyRenderData renderData;
  final VoidCallback? onTap;
  final bool isGrouped;

  @override
  DASTableRow build(BuildContext context) {
    return DASTableRow(
      height: height,
      color: rowColor,
      onTap: onTap,
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
      child: RouteCellBody(
        isCurrentPosition: metadata.currentPosition == data,
        isRouteStart: metadata.routeStart == data,
        isRouteEnd: metadata.routeEnd == data,
      ),
    );
  }

  DASTableCell trackEquipment(BuildContext context) {
    return DASTableCell(
      color: specialCellColor,
      padding: EdgeInsets.all(0.0),
      alignment: null,
      child: TrackEquipmentCellBody(
        renderData: renderData.trackEquipmentRenderData,
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
    return DASTableCell.empty();
  }

  DASTableCell advisedSpeedCell(BuildContext context) {
    return DASTableCell.empty();
  }

  DASTableCell brakedWeightSpeedCell(BuildContext context) {
    if (data.speedData == null) {
      return DASTableCell.empty();
    }

    final currentTrainSeries =
        renderData.settings.selectedBreakSeries?.trainSeries ?? metadata.breakSeries?.trainSeries;
    final currentBreakSeries =
        renderData.settings.selectedBreakSeries?.breakSeries ?? metadata.breakSeries?.breakSeries;

    return DASTableCell(
      child: Text(data.speedData!.resolvedSpeed(currentTrainSeries, currentBreakSeries) ?? 'XX'),
      alignment: Alignment.center,
    );
  }

  DASTableCell iconsCell1(BuildContext context) {
    return DASTableCell.empty();
  }

  DASTableCell bracketStation(BuildContext context) {
    final bracketStationRenderData = renderData.bracketStationRenderData;
    if (!bracketStationRenderData.isWithin) return DASTableCell.empty();

    return DASTableCell(
      padding: EdgeInsets.all(0.0),
      clipBehaviour: Clip.none,
      child: BracketStationCellBody(
        stationAbbreviation:
            renderData.bracketStationRenderData.isStart ? bracketStationRenderData.stationAbbreviation : null,
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
}

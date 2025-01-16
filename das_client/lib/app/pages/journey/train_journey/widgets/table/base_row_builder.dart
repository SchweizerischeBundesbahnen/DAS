import 'package:das_client/app/model/train_journey_settings.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/additional_speed_restriction_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/graduated_speeds_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/track_equipment_render_data.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/model/journey/additional_speed_restriction.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/speed_data.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BaseRowBuilder<T extends BaseData> extends DASTableRowBuilder {
  static const double rowHeight = 44.0;

  const BaseRowBuilder({
    required this.metadata,
    required this.data,
    required this.settings,
    super.height = rowHeight,
    this.trackEquipmentRenderData = const TrackEquipmentRenderData(),
    this.defaultAlignment = Alignment.bottomCenter,
    this.rowColor,
    this.onTap,
    this.isGrouped = false,
  });

  final Alignment defaultAlignment;
  final Color? rowColor;
  final Metadata metadata;
  final T data;
  final TrackEquipmentRenderData trackEquipmentRenderData;
  final TrainJourneySettings settings;
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
        renderData: trackEquipmentRenderData,
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

    final currentTrainSeries = settings.selectedBreakSeries?.trainSeries ?? metadata.breakSeries?.trainSeries;
    final currentBreakSeries = settings.selectedBreakSeries?.breakSeries ?? metadata.breakSeries?.breakSeries;

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

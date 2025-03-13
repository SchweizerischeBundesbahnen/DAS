import 'package:das_client/app/pages/journey/train_journey/widgets/table/additional_speed_restriction_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/bracket_station_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/train_journey_config.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/model/journey/additional_speed_restriction.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

// TODO: Handle file structure with multiple tables that share cells
class ReducedBaseRowBuilder<T extends BaseData> extends DASTableRowBuilder {
  static const double rowHeight = 44.0;

  const ReducedBaseRowBuilder({
    required this.metadata,
    required this.data,
    super.height = rowHeight,
    this.config = const TrainJourneyConfig(),
    this.defaultAlignment = Alignment.bottomCenter,
    this.rowColor,
    this.onTap,
  });

  final Alignment defaultAlignment;
  final Color? rowColor;
  final Metadata metadata;
  final T data;
  final TrainJourneyConfig config;
  final VoidCallback? onTap;

  @override
  DASTableRow build(BuildContext context) {
    return DASTableRow(
      height: height,
      color: rowColor,
      onTap: onTap,
      cells: [
        timeCell(context),
        routeCell(context),
        bracketStation(context),
        informationCell(context),
        iconsCell(context),
        speedCell(context),
        communicationNetworkCell(context),
      ],
    );
  }

  DASTableCell routeCell(BuildContext context) {
    return DASTableCell(
      color: specialCellColor,
      padding: EdgeInsets.all(0.0).copyWith(right: sbbDefaultSpacing),
      alignment: null,
      clipBehaviour: Clip.none,
      child: RouteCellBody(
        isRouteStart: metadata.routeStart == data,
        isRouteEnd: metadata.routeEnd == data,
      ),
    );
  }

  DASTableCell timeCell(BuildContext context) {
    return DASTableCell.empty(color: specialCellColor);
  }

  DASTableCell informationCell(BuildContext context) {
    return DASTableCell.empty();
  }

  DASTableCell speedCell(BuildContext context) {
    return DASTableCell.empty();
  }

  // TODO: Implement communication cell
  DASTableCell communicationNetworkCell(BuildContext context) {
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

  DASTableCell iconsCell(BuildContext context) {
    return DASTableCell.empty();
  }

  Color? get specialCellColor =>
      getAdditionalSpeedRestriction() != null ? AdditionalSpeedRestrictionRow.additionalSpeedRestrictionColor : null;

  AdditionalSpeedRestriction? getAdditionalSpeedRestriction() {
    return metadata.additionalSpeedRestrictions
        .where((it) =>
            it.orderFrom <= data.order &&
            it.orderTo >= data.order &&
            it.isDisplayed(metadata.nonStandardTrackEquipmentSegments))
        .firstOrNull;
  }
}

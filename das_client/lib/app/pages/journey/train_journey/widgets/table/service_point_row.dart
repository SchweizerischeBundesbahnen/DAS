import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/bracket_station_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/graduated_speeds_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ServicePointRow extends BaseRowBuilder<ServicePoint> {
  static const Key stopOnRequestKey = Key('stop_on_request_key');

  static const double rowHeight = 64.0;

  ServicePointRow({
    required super.metadata,
    required super.data,
    required super.settings,
    super.height = rowHeight,
    super.trackEquipmentRenderData,
  }) : super(rowColor: metadata.nextStop == data ? SBBColors.royal.withAlpha((255.0 * 0.2).round()) : null);

  @override
  DASTableCell informationCell(BuildContext context) {
    final servicePointName = data.name.localized;
    final textStyle =
        data.isStation ? DASTextStyles.xLargeBold : DASTextStyles.xLargeLight.copyWith(fontStyle: FontStyle.italic);
    return DASTableCell(
      alignment: defaultAlignment,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(servicePointName, style: textStyle),
        ],
      ),
    );
  }

  @override
  DASTableCell timeCell(BuildContext context) {
    return DASTableCell(child: Text('06:05:52'), alignment: defaultAlignment, color: specialCellColor);
  }

  @override
  DASTableCell iconsCell1(BuildContext context) {
    return DASTableCell(
      padding: EdgeInsets.fromLTRB(0, sbbDefaultSpacing * 0.5, 0, sbbDefaultSpacing * 0.5),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (data.bracketStation != null) _bracketStationCell(),
          if (!data.mandatoryStop) _stopOnRequestIcon()
        ],
      ),
    );
  }

  @override
  DASTableCell routeCell(BuildContext context) {
    return DASTableCell(
      color: specialCellColor,
      padding: EdgeInsets.all(0.0),
      alignment: null,
      child: RouteCellBody(
        isStop: data.isStop,
        isCurrentPosition: metadata.currentPosition == data,
        isRouteStart: metadata.routeStart == data,
        isRouteEnd: metadata.routeEnd == data,
        isStopOnRequest: !data.mandatoryStop,
      ),
    );
  }

  @override
  DASTableCell localSpeedCell(BuildContext context) {
    if (data.stationSpeedData == null) return DASTableCell.empty();

    final currentTrainSeries = settings.selectedBreakSeries?.trainSeries ?? metadata.breakSeries?.trainSeries;
    final currentBreakSeries = settings.selectedBreakSeries?.breakSeries ?? metadata.breakSeries?.breakSeries;

    final graduatedSpeeds = data.stationSpeedData!.graduatedSpeedsFor(currentTrainSeries, currentBreakSeries);
    if (graduatedSpeeds == null) return DASTableCell.empty();

    return DASTableCell(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: sbbDefaultSpacing * 0.5),
      child: GraduatedSpeedsCellBody(
        incomingSpeeds: graduatedSpeeds.incomingSpeeds,
        outgoingSpeeds: graduatedSpeeds.outgoingSpeeds,
      ),
    );
  }

  @override
  DASTableCell trackEquipment(BuildContext context) {
    return DASTableCell(
      color: specialCellColor,
      padding: const EdgeInsets.all(0.0),
      alignment: null,
      child: TrackEquipmentCellBody(
        renderData: trackEquipmentRenderData,
      ),
    );
  }

  Widget _stopOnRequestIcon() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SvgPicture.asset(
        AppAssets.iconStopOnRequest,
        key: stopOnRequestKey,
      ),
    );
  }

  Widget _bracketStationCell() {
    return BracketStationCellBody(
      bracketStation: data.bracketStation!,
      height: height,
    );
  }
}

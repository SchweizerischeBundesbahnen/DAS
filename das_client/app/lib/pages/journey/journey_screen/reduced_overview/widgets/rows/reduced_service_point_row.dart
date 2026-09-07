import 'package:app/extension/short_term_change_extension.dart';
import 'package:app/pages/journey/journey_screen/view_model/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/chevron_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/route_variant.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_cell_body.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/service_point_information_cell_title.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/time_cell_body.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/service_point_row.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class ReducedServicePointRow extends ServicePointRow {
  ReducedServicePointRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.context,
    super.config,
    super.key,
    this._routeVariant,
  }) : super(
         rowColor: ThemeUtil.getDASTableColor(context),
         journeyPosition: JourneyPositionModel(),
         chevronPosition: ChevronPositionModel(),
         highlightNextStop: false,
         height: calculateHeight(_routeVariant),
       );

  final RouteVariant? _routeVariant;

  @override
  DASTableCell informationCell(BuildContext context) {
    ShortTermChange? shortTermChange = metadata.shortTermChanges.appliesToOrder(data.order).getHighestPriority;
    if (shortTermChange != null) {
      shortTermChange = shortTermChange.startData == data ? shortTermChange : null;
    }

    return DASTableCell(
      alignment: .bottomLeft,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          ServicePointInformationCellTitle(
            isModalOpenValue: isModalOpenValue(context),
            isModalOpenStream: isModalOpenStream(context),
            name: data.betweenBrackets ? '(${data.name})' : data.name,
            foregroundColor: null,
            isStation: data.isStation,
            trackGroup: data.trackGroup,
            shortTermChange: shortTermChange,
          ),
          _routeVariantText(context),
        ],
      ),
    );
  }

  @override
  DASTableCell localSpeedCell(BuildContext context) {
    return DASTableCell.empty();
  }

  @override
  DASTableCell timeCell(BuildContext context) {
    final times = data.arrivalDepartureTime;
    if (times == null && data.mandatoryStop) {
      return DASTableCell.empty(
        decoration: DASTableCellDecoration(color: specialCellColor),
      );
    }

    final viewModel = context.read<ArrivalDepartureTimeViewModel>();

    return DASTableCell(
      child: TimeCellBody(
        viewModel: viewModel,
        times: times,
        showTimesInBrackets: !data.isStop,
        mandatoryStop: data.mandatoryStop,
      ),
      alignment: .bottomLeft,
      decoration: DASTableCellDecoration(color: specialCellColor),
    );
  }

  @override
  bool get shouldOpenDetailModalOnTap => false;

  @override
  DASTableCell routeCell(BuildContext context) {
    final vm = context.read<JourneyTableViewModel>();

    return DASTableCell(
      decoration: DASTableCellDecoration(color: specialCellColor),
      padding: .all(0.0),
      alignment: null,
      clipBehavior: .none,
      child: RouteCellBody(
        isStop: data.isStop,
        isCurrentPosition: false,
        isRouteStart: vm.journeyStart == data,
        isRouteEnd: vm.journeyEnd == data,
        isStopOnRequest: !data.mandatoryStop,
        chevronPosition: calculatedChevronPosition,
      ),
    );
  }

  @override
  Stream<bool> isModalOpenStream(BuildContext context) => Stream.value(false).asBroadcastStream();

  @override
  bool isModalOpenValue(BuildContext context) => false;

  Widget _routeVariantText(BuildContext context) {
    if (_routeVariant == null) return SizedBox.shrink();

    return Text(
      _routeVariant.localizedName(context),
      style: sbbTextStyle.romanStyle.medium,
    );
  }

  static double calculateHeight(RouteVariant? routeVariant) {
    if (routeVariant == null) return ServicePointRow.baseRowHeight;
    return ServicePointRow.baseRowHeight + SBBSpacing.xSmall;
  }
}

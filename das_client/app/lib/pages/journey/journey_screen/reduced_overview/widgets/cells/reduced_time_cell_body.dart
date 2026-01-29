import 'package:app/pages/journey/journey_screen/widgets/table/service_point_row.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class ReducedTimeCellBody extends StatelessWidget {
  static const timeCellKey = Key('reducedTimeCell');

  const ReducedTimeCellBody({
    required this.showTimesInBrackets,
    required this.mandatoryStop,
    this.times,
    super.key,
  });

  final ArrivalDepartureTime? times;
  final bool mandatoryStop;
  final bool showTimesInBrackets;

  @override
  Widget build(BuildContext context) {
    final (departureTime, arrivalTime) = _formattedTimes();

    if (departureTime.isEmpty && arrivalTime.isEmpty && mandatoryStop) {
      return SizedBox.shrink(key: DASTableCell.emptyCellKey);
    }

    final isArrivalBold = departureTime.isEmpty;

    final timeTexts = Text.rich(
      key: timeCellKey,
      TextSpan(
        children: [
          TextSpan(text: arrivalTime, style: isArrivalBold ? sbbTextStyle.boldStyle.large : null),
          TextSpan(text: departureTime, style: sbbTextStyle.boldStyle.large),
        ],
      ),
    );

    if (mandatoryStop) return timeTexts;
    if (!mandatoryStop && departureTime.isEmpty && arrivalTime.isEmpty) {
      return Align(alignment: .centerRight, child: _mandatoryStopIcon(context));
    }

    return Row(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      spacing: SBBSpacing.xxSmall,
      children: [
        timeTexts,
        Align(alignment: .topRight, child: _mandatoryStopIcon(context)),
      ],
    );
  }

  SvgPicture _mandatoryStopIcon(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.iconStopOnRequest,
      key: ServicePointRow.stopOnRequestKey,
      colorFilter: ColorFilter.mode(
        ThemeUtil.getIconColor(context),
        BlendMode.srcIn,
      ),
    );
  }

  (String, String) _formattedTimes() {
    String departureTime = '';
    String arrivalTime = '';

    departureTime = Format.plannedTime(times?.plannedDepartureTime);
    arrivalTime = Format.plannedTime(times?.plannedArrivalTime);

    if (showTimesInBrackets) {
      departureTime = departureTime.isNotEmpty ? '($departureTime)' : departureTime;
      arrivalTime = arrivalTime.isNotEmpty ? '($arrivalTime)' : arrivalTime;
    }

    arrivalTime = arrivalTime.isNotEmpty ? '$arrivalTime\n' : arrivalTime;

    return (departureTime, arrivalTime);
  }
}

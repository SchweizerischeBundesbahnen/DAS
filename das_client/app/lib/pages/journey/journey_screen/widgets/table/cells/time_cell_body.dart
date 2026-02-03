import 'package:app/extension/arrival_departure_time_extension.dart';
import 'package:app/extension/datetime_extension.dart';
import 'package:app/pages/journey/journey_screen/view_model/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/service_point_row.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class TimeCellBody extends StatelessWidget {
  static const timeCellKey = Key('timeCellKey');

  const TimeCellBody({
    required this.viewModel,
    required this.showTimesInBrackets,
    required this.mandatoryStop,
    this.times,
    this.fontColor,
    super.key,
  });

  final ArrivalDepartureTime? times;
  final ArrivalDepartureTimeViewModel viewModel;
  final bool showTimesInBrackets;
  final bool mandatoryStop;
  final Color? fontColor;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CombineLatestStream.combine2<bool, DateTime, (bool, DateTime)>(
        viewModel.showOperationalTime,
        viewModel.wallclockTimeToMinute,
        (a, b) => (a, b),
      ),
      initialData: (viewModel.showOperationalTimeValue, viewModel.wallclockTimeToMinuteValue),
      builder: (context, snapshot) {
        final showOperationalTime = snapshot.requireData.$1;
        final currentTime = snapshot.requireData.$2;

        final (departureTime, arrivalTime) = times.formattedTimes(
          showOperationalTime: showOperationalTime,
          showTimesInBrackets: showTimesInBrackets,
        );

        if (departureTime.isEmpty && arrivalTime.isEmpty && mandatoryStop) {
          return SizedBox.shrink(key: DASTableCell.emptyCellKey);
        }

        final isArrivalBold = departureTime.isEmpty && !showOperationalTime;
        final isDepartureUnderlined = currentTime.isAfterOrSameToTheMinute(times?.plannedDepartureTime);

        final timeTexts = Text.rich(
          key: timeCellKey,
          TextSpan(
            children: [
              TextSpan(
                text: arrivalTime,
                style: isArrivalBold
                    ? sbbTextStyle.boldStyle.large.copyWith(color: fontColor)
                    : sbbTextStyle.romanStyle.large.copyWith(color: fontColor),
              ),
              TextSpan(
                text: departureTime,
                style: sbbTextStyle.boldStyle.large.copyWith(
                  decoration: isDepartureUnderlined ? TextDecoration.underline : TextDecoration.none,
                  color: fontColor,
                ),
              ),
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
      },
    );
  }

  SvgPicture _mandatoryStopIcon(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.iconStopOnRequest,
      key: ServicePointRow.stopOnRequestKey,
      colorFilter: ColorFilter.mode(
        fontColor ?? ThemeUtil.getIconColor(context),
        BlendMode.srcIn,
      ),
    );
  }
}

extension _DateTimeExtension on DateTime {
  bool isAfterOrSameToTheMinute(DateTime? other) {
    if (other == null) return false;
    return roundDownToMinute.isAfterOrSame(other.roundDownToMinute);
  }

  bool isAfterOrSame(DateTime other) => isAtSameMomentAs(other) || isAfter(other);
}

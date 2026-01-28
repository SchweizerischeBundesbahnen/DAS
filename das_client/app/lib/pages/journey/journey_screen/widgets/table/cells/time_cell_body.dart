import 'package:app/extension/datetime_extension.dart';
import 'package:app/pages/journey/journey_screen/view_model/arrival_departure_time_view_model.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class TimeCellBody extends StatelessWidget {
  static const timeCellKey = Key('timeCellKey');

  const TimeCellBody({
    required this.times,
    required this.viewModel,
    required this.showTimesInBrackets,
    this.fontColor,
    super.key,
  });

  final ArrivalDepartureTime times;
  final ArrivalDepartureTimeViewModel viewModel;
  final bool showTimesInBrackets;
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

        final (departureTime, arrivalTime) = _formattedTimes(showOperationalTime);

        if (departureTime.isEmpty && arrivalTime.isEmpty) {
          return SizedBox.shrink(key: DASTableCell.emptyCellKey);
        }

        final isArrivalBold = departureTime.isEmpty && !showOperationalTime;
        final isDepartureUnderlined = currentTime.isAfterOrSameToTheMinute(times.plannedDepartureTime);

        return Text.rich(
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
      },
    );
  }

  (String, String) _formattedTimes(bool showOperationalTime) {
    String departureTime = '';
    String arrivalTime = '';

    if (showOperationalTime) {
      departureTime = Format.operationalTime(times.operationalDepartureTime);
      arrivalTime = Format.operationalTime(times.operationalArrivalTime);
    } else {
      departureTime = Format.plannedTime(times.plannedDepartureTime);
      arrivalTime = Format.plannedTime(times.plannedArrivalTime);
    }

    if (showTimesInBrackets) {
      departureTime = departureTime.isNotEmpty ? '($departureTime)' : departureTime;
      arrivalTime = arrivalTime.isNotEmpty ? '($arrivalTime)' : arrivalTime;
    }

    arrivalTime = arrivalTime.isNotEmpty ? '$arrivalTime\n' : arrivalTime;

    return (departureTime, arrivalTime);
  }
}

extension _DateTimeExtension on DateTime {
  bool isAfterOrSameToTheMinute(DateTime? other) {
    if (other == null) return false;
    return roundDownToMinute.isAfterOrSame(other.roundDownToMinute);
  }

  bool isAfterOrSame(DateTime other) => isAtSameMomentAs(other) || isAfter(other);
}

import 'package:app/util/format.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

class ReducedTimeCellBody extends StatelessWidget {
  static const timeCellKey = Key('reducedTimeCell');

  const ReducedTimeCellBody({
    required this.times,
    required this.showTimesInBrackets,
    super.key,
  });

  final ArrivalDepartureTime times;
  final bool showTimesInBrackets;

  @override
  Widget build(BuildContext context) {
    final (departureTime, arrivalTime) = _formattedTimes();

    if (departureTime.isEmpty && arrivalTime.isEmpty) return SizedBox.shrink(key: DASTableCell.emptyCellKey);

    final isArrivalBold = departureTime.isEmpty;

    return Text.rich(
      key: timeCellKey,
      TextSpan(
        children: [
          TextSpan(text: arrivalTime, style: isArrivalBold ? DASTextStyles.largeBold : null),
          TextSpan(text: departureTime, style: DASTextStyles.largeBold),
        ],
      ),
    );
  }

  (String, String) _formattedTimes() {
    String departureTime = '';
    String arrivalTime = '';

    departureTime = Format.plannedTime(times.plannedDepartureTime);
    arrivalTime = Format.plannedTime(times.plannedArrivalTime);

    if (showTimesInBrackets) {
      departureTime = departureTime.isNotEmpty ? '($departureTime)' : departureTime;
      arrivalTime = arrivalTime.isNotEmpty ? '($arrivalTime)' : arrivalTime;
    }

    arrivalTime = arrivalTime.isNotEmpty ? '$arrivalTime\n' : arrivalTime;

    return (departureTime, arrivalTime);
  }
}

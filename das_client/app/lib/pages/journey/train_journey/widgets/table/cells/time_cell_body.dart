import 'package:app/pages/journey/train_journey/widgets/table/arrival_departure_time/arrival_departure_time_view_model.dart';
import 'package:app/util/format.dart';
import 'package:app/util/time_format.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

class TimeCellBody extends StatelessWidget {
  static const timeCellKey = Key('timeCellKey');

  const TimeCellBody({
    required this.times,
    required this.viewModel,
    required this.showTimesInBrackets,
    super.key,
  });

  final ArrivalDepartureTime times;
  final ArrivalDepartureTimeViewModel viewModel;
  final bool showTimesInBrackets;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: viewModel.showOperationalTime,
      initialData: viewModel.showOperationalTimeValue,
      builder: (context, snapshot) {
        final showOperationalTime = snapshot.data ?? false;

        final (depTime, arrTime) = _formattedTimes(showOperationalTime);

        if (depTime.isEmpty && arrTime.isEmpty) {
          return SizedBox.shrink(key: DASTableCell.emptyCellKey);
        }

        final isArrTimeBold = depTime.isEmpty && !showOperationalTime;

        return Text.rich(
          key: timeCellKey,
          TextSpan(
            children: [
              TextSpan(text: arrTime, style: isArrTimeBold ? DASTextStyles.largeBold : null),
              TextSpan(text: depTime, style: DASTextStyles.largeBold)
            ],
          ),
        );
      },
    );
  }

  (String, String) _formattedTimes(showOperationalTime) {
    String depTime = '';
    String arrTime = '';

    if (showOperationalTime) {
      depTime = TimeFormat.operationalTime(times.operationalDepartureTime);
      arrTime = TimeFormat.operationalTime(times.operationalArrivalTime);
    } else {
      depTime = TimeFormat.plannedTime(times.plannedDepartureTime);
      arrTime = TimeFormat.plannedTime(times.plannedArrivalTime);
    }

    if (showTimesInBrackets) {
      depTime = depTime.isNotEmpty ? '($depTime)' : depTime;
      arrTime = arrTime.isNotEmpty ? '($arrTime)' : arrTime;
    }

    arrTime = arrTime.isNotEmpty ? '$arrTime\n' : arrTime;

    return (depTime, arrTime);
  }
}

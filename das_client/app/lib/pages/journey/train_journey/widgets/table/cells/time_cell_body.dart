import 'package:app/pages/journey/train_journey/widgets/table/arrival_departure_time/arrival_departure_time_view_model.dart';
import 'package:app/util/format.dart';
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
        stream: viewModel.rxShowCalculatedTimes,
        initialData: viewModel.showCalculatedTimes,
        builder: (context, snapshot) {
          final showCalculatedTimes = snapshot.data ?? false;

          bool isTimeCalculated = false;
          DateTime? depTime;
          DateTime? arrTime;
          if (showCalculatedTimes) {
            if (times.hasAnyOperationalTime) {
              // show calculated
              depTime = times.operationalDepartureTime;
              arrTime = times.operationalArrivalTime;
              isTimeCalculated = true;
            } else {
              return SizedBox.shrink(key: DASTableCell.emptyCellKey);
            }
          } else {
            // show Planned
            depTime = times.plannedDepartureTime;
            arrTime = times.plannedArrivalTime;
          }

          String formattedDepTime = '';
          String formattedArrTime = '';

          if (depTime != null) formattedDepTime = Format.time(depTime, showSeconds: true);
          if (arrTime != null) formattedArrTime = Format.time(arrTime, showSeconds: true);

          int timeLength = 5; // noSeconds
          if (isTimeCalculated) {
            timeLength = 7;
          }

          formattedDepTime = formattedDepTime.substring(
              0, timeLength <= formattedDepTime.length ? timeLength : formattedDepTime.length);
          formattedArrTime = formattedArrTime.substring(
              0, timeLength <= formattedArrTime.length ? timeLength : formattedArrTime.length);

          if (formattedDepTime.isNotEmpty && showTimesInBrackets) formattedDepTime = '($formattedDepTime)';
          if (formattedArrTime.isNotEmpty && showTimesInBrackets) formattedArrTime = '($formattedArrTime)';

          final isArrTimeBold = formattedDepTime.isEmpty && !isTimeCalculated;

          if (formattedArrTime.isNotEmpty) formattedArrTime = '$formattedArrTime\n';

          return Text.rich(
            key: timeCellKey,
            TextSpan(
              children: [
                TextSpan(text: formattedArrTime, style: isArrTimeBold ? DASTextStyles.largeBold : null),
                TextSpan(text: formattedDepTime, style: DASTextStyles.largeBold)
              ],
            ),
          );
        });
  }
}

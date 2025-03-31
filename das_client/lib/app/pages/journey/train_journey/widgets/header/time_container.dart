import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class TimeContainer extends StatelessWidget {
  const TimeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      margin: const EdgeInsetsDirectional.fromSTEB(
        sbbDefaultSpacing * 0.5,
        0,
        sbbDefaultSpacing * 0.5,
        sbbDefaultSpacing * 0.5,
      ),
      padding: const EdgeInsets.all(sbbDefaultSpacing),
      useShadow: false,
      child: SizedBox(
        width: 124.0,
        height: 112.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(child: _currentTime()),
            _divider(),
            Flexible(child: _punctualityDisplay(context)),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.5),
      child: Divider(height: 1.0, color: SBBColors.cloud),
    );
  }

  Widget _punctualityDisplay(BuildContext context) {
    return StreamBuilder<Journey?>(
      stream: context.trainJourneyCubit.journeyStream,
      builder: (context, snapshot) {
        var punctualityString = '+00:00';
        final delay = snapshot.data?.metadata.delay;
        if (delay != null) {
          final String minutes = NumberFormat('00').format(delay.inMinutes.abs() % 60);
          final String seconds = NumberFormat('00').format(delay.inSeconds.abs() % 60);
          punctualityString = '${delay.isNegative ? '-' : '+'}$minutes:$seconds';
        }

        return Padding(
          padding:
              const EdgeInsets.fromLTRB(sbbDefaultSpacing * 0.5, 0.0, sbbDefaultSpacing * 0.5, sbbDefaultSpacing * 0.5),
          child: Text(punctualityString, style: DASTextStyles.xLargeLight),
        );
      },
    );
  }

  Widget _currentTime() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 200)),
      builder: (context, snapshot) {
        return Padding(
          padding:
              const EdgeInsets.fromLTRB(sbbDefaultSpacing * 0.5, sbbDefaultSpacing * 0.5, sbbDefaultSpacing * 0.5, 0),
          child: Text(
            DateFormat('HH:mm:ss').format(DateTime.now().toLocal()),
            style: DASTextStyles.xLargeBold,
          ),
        );
      },
    );
  }
}

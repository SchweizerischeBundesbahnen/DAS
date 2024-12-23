import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:flutter/material.dart';
import 'package:das_client/model/journey/journey.dart';
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
        sbbDefaultSpacing,
      ),
      padding: const EdgeInsets.all(sbbDefaultSpacing),
      useShadow: false,
      child: SizedBox(
        width: 124.0,
        height: 112.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(child: _currentTime()),
            _divider(),
            Flexible(child: _punctualityDisplay(context)),
          ],
        ),
      ),
    );
  }
}

Widget _divider() {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.5),
    child: Divider(height: 1.0, color: SBBColors.cloud),
  );
}

Widget _punctualityDisplay(BuildContext context) {
  final bloc = context.trainJourneyCubit;

  return StreamBuilder<Journey?>(
      stream: bloc.journeyStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.metadata.delay == null) {
          return Center(
            //SBBLoadingIndicator doesn't work here. It is not being showed
            child: CircularProgressIndicator(),
          );
        }
        final Journey journey = snapshot.data!;

        final Duration delay = journey.metadata.delay!;

        final String minutes = (delay.inMinutes.abs() % 60).toString();
        final String seconds = (delay.inSeconds.abs() % 60).toString();
        final String hours = delay.inHours.abs().toString();
        final String formattedDuration = '${delay.isNegative ? '-' : '+'}$hours:$minutes:${seconds.padLeft(2, '0')}';
        return Text(
          formattedDuration,
          style: SBBTextStyles.largeLight.copyWith(fontSize: 24.0),
        );
      });
}

StreamBuilder _currentTime() {
  return StreamBuilder(
    stream: Stream.periodic(const Duration(seconds: 1)),
    builder: (context, snapshot) {
      return Text(
        DateFormat('HH:mm:ss').format(DateTime.now().toLocal()),
        style: SBBTextStyles.largeBold.copyWith(fontSize: 24.0),
      );
    },
  );
}

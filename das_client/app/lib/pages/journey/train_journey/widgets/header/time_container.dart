import 'dart:async';

import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_state_enum.dart';
import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_view_model.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class TimeContainer extends StatefulWidget {
  static const String trainIsPunctualString = '+00:00';
  static const Key delayKey = Key('delayTextKey');

  const TimeContainer({super.key});

  @override
  State<TimeContainer> createState() => TimeContainerState();
}

class TimeContainerState extends State<TimeContainer> {
  late PunctualityViewModel punctualityController;
  TrainJourneyViewModel? viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = context.read<TrainJourneyViewModel>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Journey?>(
      stream: viewModel!.journey,
      builder: (context, snapshot) {
        final journey = snapshot.data;

        return SBBGroup(
          padding: const EdgeInsets.all(sbbDefaultSpacing),
          useShadow: false,
          child: SizedBox(
            width: 124.0,
            height: 112.0,
            child: _buildDelayColumn(journey),
          ),
        );
      },
    );
  }

  Widget _buildDelayColumn(Journey? journey) {
    return StreamBuilder<PunctualityState>(
      stream: punctualityController.punctualityState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? PunctualityState.visible;
        final delay = _delay(journey, state);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(child: _currentTime()),
            _divider(),
            state != PunctualityState.hidden ? Flexible(child: delay) : SizedBox(height: sbbDefaultSpacing * 2.5),
          ],
        );
      },
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.5),
      child: Divider(height: 1.0, color: SBBColors.cloud),
    );
  }

  Widget _delay(Journey? journey, PunctualityState punctualityState) {
    final delayValue = _resolveDelayString(journey);
    final TextStyle resolvedStyle = _resolvedDelayStyle(punctualityState);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        sbbDefaultSpacing * 0.5,
        0.0,
        sbbDefaultSpacing * 0.5,
        sbbDefaultSpacing * 0.5,
      ),
      child: Text(delayValue, style: resolvedStyle, key: TimeContainer.delayKey),
    );
  }

  TextStyle _resolvedDelayStyle(PunctualityState punctualityState) {
    final resolvedStyle = punctualityState == PunctualityState.stale
        ? DASTextStyles.xLargeLight.copyWith(
            color: ThemeUtil.getColor(context, SBBColors.graphite, SBBColors.granite),
          )
        : DASTextStyles.xLargeLight;
    return resolvedStyle;
  }

  String _resolveDelayString(Journey? journey) {
    String delayString = TimeContainer.trainIsPunctualString;
    final delay = journey?.metadata.delay?.delay;
    if (delay != null) {
      final minutes = NumberFormat('00').format(delay.inMinutes.abs());
      final seconds = NumberFormat('00').format(delay.inSeconds.abs() % 60);
      delayString = '${delay.isNegative ? '-' : '+'}$minutes:$seconds';
    }
    return delayString;
  }

  Widget _currentTime() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 200)),
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            sbbDefaultSpacing * 0.5,
            sbbDefaultSpacing * 0.5,
            sbbDefaultSpacing * 0.5,
            0,
          ),
          child: Text(
            DateFormat('HH:mm:ss').format(clock.now()),
            style: DASTextStyles.xLargeBold,
          ),
        );
      },
    );
  }
}

import 'dart:async';
import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_controller.dart';
import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_state_enum.dart';
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
  const TimeContainer({super.key});

  static const Key delayKey = Key('delayTextKey');

  @override
  State<TimeContainer> createState() => TimeContainerState();
}

class TimeContainerState extends State<TimeContainer> {
  late PunctualityController punctualityController;
  TrainJourneyViewModel? viewModel;

  @override
  void initState() {
    super.initState();
    punctualityController = PunctualityController();
    punctualityController.lastUpdate = clock.now();
    punctualityController.startMonitoring();
    viewModel = context.read<TrainJourneyViewModel>();
  }

  @override
  void dispose() {
    punctualityController.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Journey?>(
      stream: viewModel!.journey,
      builder: (context, snapshot) {
        final journey = snapshot.data;
        punctualityController.updatePunctualityTimestamp(journey?.metadata.delay);

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
      stream: punctualityController.punctualityStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? PunctualityState.visible;
        final delay = journey?.metadata.delay;
        final delayText = _buildDelayText(delay?.delay, state);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(child: _currentTime()),
            _divider(),
            state != PunctualityState.hidden ? Flexible(child: delayText) : SizedBox(height: sbbDefaultSpacing * 2.5),
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

  Widget _buildDelayText(Duration? delay, PunctualityState punctualityState) {
    String delayString = '+00:00';
    if (delay != null) {
      final minutes = NumberFormat('00').format(delay.inMinutes.abs());
      final seconds = NumberFormat('00').format(delay.inSeconds.abs() % 60);
      delayString = '${delay.isNegative ? '-' : '+'}$minutes:$seconds';
    }

    final style = punctualityState == PunctualityState.stale
        ? DASTextStyles.xLargeLight.copyWith(
            color: ThemeUtil.getColor(context, SBBColors.graphite, SBBColors.granite),
          )
        : DASTextStyles.xLargeLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        sbbDefaultSpacing * 0.5,
        0.0,
        sbbDefaultSpacing * 0.5,
        sbbDefaultSpacing * 0.5,
      ),
      child: Text(delayString, style: style, key: TimeContainer.delayKey),
    );
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

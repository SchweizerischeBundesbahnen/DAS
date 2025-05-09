import 'dart:async';
import 'package:app/bloc/train_journey_cubit.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/time_controller/time_controller.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class TimeContainer extends StatefulWidget {
  const TimeContainer({super.key});

  @override
  State<TimeContainer> createState() => _TimeContainerState();
}

class _TimeContainerState extends State<TimeContainer> {
  DateTime _lastUpdate = DateTime.now();
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeController = TimeController();

    final sinceUpdate = DateTime.now().difference(_lastUpdate);
    final isStale = sinceUpdate > Duration(seconds: timeController.punctualityStaleSeconds);
    final isVisible = sinceUpdate < Duration(seconds: timeController.punctualityDisappearSeconds);

    return StreamBuilder<Journey?>(
      stream: context.trainJourneyCubit.journeyStream,
      builder: (context, snapshot) {
        final journey = snapshot.data;
        final delay = journey?.metadata.delay;

        if (delay != null) {
          final oldSince = DateTime.now().difference(_lastUpdate);
          final wasStale = oldSince > Duration(seconds: timeController.punctualityStaleSeconds);
          final wasInvisible = oldSince > Duration(seconds: timeController.punctualityDisappearSeconds);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _lastUpdate = DateTime.now();
              if (wasStale || wasInvisible) {
                setState(() {});
              }
            }
          });
        }

        final delayText = _buildDelayText(delay, isStale);

        return SBBGroup(
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
                if (isVisible) Flexible(child: delayText) else SizedBox(height: sbbDefaultSpacing * 2.5),
              ],
            ),
          ),
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

  Widget _buildDelayText(Duration? delay, bool isStale) {
    String delayString = '+00:00';
    if (delay != null) {
      final minutes = NumberFormat('00').format(delay.inMinutes.abs());
      final seconds = NumberFormat('00').format(delay.inSeconds.abs() % 60);
      delayString = '${delay.isNegative ? '-' : '+'}$minutes:$seconds';
    }

    final style = isStale
        ? DASTextStyles.xLargeLight.copyWith(
            color: ThemeUtil.getColor(context, SBBColors.graphite, SBBColors.granite),
          )
        : DASTextStyles.xLargeLight;

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(sbbDefaultSpacing * 0.5, 0.0, sbbDefaultSpacing * 0.5, sbbDefaultSpacing * 0.5),
      child: Text(delayString, style: style),
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
            DateFormat('HH:mm:ss').format(DateTime.now()),
            style: DASTextStyles.xLargeBold,
          ),
        );
      },
    );
  }
}

import 'dart:async';

import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/theme/theme_util.dart';
import 'package:das_client/time_controller/time_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class TimeContainer extends StatefulWidget {
  const TimeContainer({super.key});

  @override
  State<TimeContainer> createState() => _TimeContainerState();
}

//TODO still have to add that when first no update comes and the PüA disappears it needs to reappear as soon as an update arrives

class _TimeContainerState extends State<TimeContainer> {
  DateTime? _lastUpdate;
  late final Timer _checkTimer;
  final DateTime _initialRenderTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _checkTimer = Timer.periodic(const Duration(milliseconds: 100), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _checkTimer.cancel();
    super.dispose();
  }

  Duration _timeSinceUpdate() {
    return _lastUpdate == null
        ? DateTime.now().difference(_initialRenderTime)
        : DateTime.now().difference(_lastUpdate!);
  }

  @override
  Widget build(BuildContext context) {
    final Duration sinceUpdate = _timeSinceUpdate();
    final timeController = TimeController();
    final staleTime = timeController.punctualityStaleSeconds;
    final disappearTime = timeController.punctualityDisappearSeconds;
    final bool isStale = sinceUpdate > Duration(seconds: staleTime);
    final bool isVisible = sinceUpdate < Duration(seconds: disappearTime);

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
            if (isVisible)
              Flexible(child: _punctualityDisplay(context, isStale))
            else
              SizedBox(
                height: sbbDefaultSpacing * 2.5,
              ),
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

  Widget _punctualityDisplay(BuildContext context, bool isStale) {
    return StreamBuilder<Journey?>(
      stream: context.trainJourneyCubit.journeyStream,
      builder: (context, snapshot) {
        final delay = snapshot.data?.metadata.delay;
        if (delay != null) {
          _lastUpdate = DateTime.now();
        }

        var punctualityString = '+00:00';
        if (delay != null) {
          final minutes = NumberFormat('00').format(delay.inMinutes.abs() % 60);
          final seconds = NumberFormat('00').format(delay.inSeconds.abs() % 60);
          punctualityString = '${delay.isNegative ? '-' : '+'}$minutes:$seconds';
        }

        final style = isStale
            ? DASTextStyles.xLargeLight
                .copyWith(color: ThemeUtil.getColor(context, SBBColors.graphite, SBBColors.granite))
            : DASTextStyles.xLargeLight;

        return Padding(
          padding:
              const EdgeInsets.fromLTRB(sbbDefaultSpacing * 0.5, 0.0, sbbDefaultSpacing * 0.5, sbbDefaultSpacing * 0.5),
          child: Text(punctualityString, style: style),
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

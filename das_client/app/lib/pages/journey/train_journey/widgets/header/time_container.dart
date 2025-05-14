import 'dart:async';
import 'package:app/bloc/train_journey_cubit.dart';
import 'package:app/di.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/time_controller/time_controller.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class TimeContainer extends StatefulWidget {
  const TimeContainer({super.key});

  static const Key delayKey = Key('delayTextKey');

  @override
  State<TimeContainer> createState() => _TimeContainerState();
}

class _TimeContainerState extends State<TimeContainer> {
  DateTime _lastUpdate = DateTime.now();
  Journey? _previousJourney;
  bool _wasVisible = true;
  Timer? _updateTimer;
  TimeController? timeController;

  @override
  void initState() {
    super.initState();
    timeController = DI.get<TimeController>();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
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
    return StreamBuilder<Journey?>(
      stream: context.trainJourneyCubit.journeyStream,
      builder: (context, snapshot) {
        final sinceUpdate = DateTime.now().difference(_lastUpdate);
        final isStale = sinceUpdate > Duration(seconds: timeController!.punctualityStaleSeconds);
        final isVisible = sinceUpdate < Duration(seconds: timeController!.punctualityDisappearSeconds);

        final journey = snapshot.data;
        final delay = journey?.metadata.delay;

        _handleUpdate(journey, delay, isVisible);

        final delayText = _buildDelayText(delay, isStale);

        return SBBGroup(
          padding: const EdgeInsets.all(sbbDefaultSpacing),
          useShadow: false,
          child: SizedBox(
            width: 124.0,
            height: 112.0,
            child: _buildDelayColumn(isVisible, delayText),
          ),
        );
      },
    );
  }

  void _handleUpdate(Journey? newJourney, Duration? delay, bool isVisible) {
    final journey = newJourney;

    if (delay != null && journey != _previousJourney) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _lastUpdate = DateTime.now();
          _previousJourney = journey;
          _wasVisible = true;
          setState(() {});
        }
      });
    }

    if (!_wasVisible && isVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _wasVisible = true;
          setState(() {});
        }
      });
    }

    if (!isVisible && _wasVisible) {
      _wasVisible = false;
    }
  }

  Widget _buildDelayColumn(bool isVisible, Widget delayText) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(child: _currentTime()),
        _divider(),
        isVisible ? Flexible(child: delayText) : SizedBox(height: sbbDefaultSpacing * 2.5),
      ],
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

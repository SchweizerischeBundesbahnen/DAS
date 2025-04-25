import 'dart:async';
import 'package:das_client/brightness/brightness_util.dart';
import 'package:flutter/material.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/main_container.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/time_container.dart';
import 'package:das_client/app/widgets/extended_header_container.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class Header extends StatefulWidget {
  final BrightnessUtil brightnessUtil;

  const Header({
    required this.brightnessUtil,
    super.key,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Timer? _dimmingTimer;
  late final BrightnessUtil _brightnessUtil;

  @override
  void initState() {
    _brightnessUtil = widget.brightnessUtil;
    _brightnessUtil.setBrightness(1);
    super.initState();
  }

  void _startDimming() async {
    _dimmingTimer?.cancel();
    final value = await _brightnessUtil.getCurrentBrightness();
    final shouldDim = value >= 0.5;

    _dimmingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      final current = await _brightnessUtil.getCurrentBrightness();
      final newValue = shouldDim ? (current - 0.05).clamp(0.0, 1.0) : (current + 0.05).clamp(0.0, 1.0);
      await _brightnessUtil.setBrightness(newValue);
      if (newValue == 0.0 || newValue == 1.0) timer.cancel();
    });
  }

  void _stopDimming() {
    _dimmingTimer?.cancel();
  }

  void _doubleTap() async {
    final current = await _brightnessUtil.getCurrentBrightness();
    final newBrightness = current < 0.5 ? 1.0 : 0.1;
    await _brightnessUtil.setBrightness(newBrightness);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) async {
    double value = await _brightnessUtil.getCurrentBrightness();
    value += details.delta.dx > 0 ? 0.01 : -0.01;
    await _brightnessUtil.setBrightness(value.clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedAppBarWrapper(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        child: Padding(
          padding: const EdgeInsets.all(sbbDefaultSpacing * 0.5).copyWith(top: 0),
          child: Row(
            spacing: sbbDefaultSpacing * 0.5,
            children: [
              Expanded(child: MainContainer()),
              GestureDetector(
                onLongPressStart: (_) => _startDimming(),
                onLongPressEnd: (_) => _stopDimming(),
                onDoubleTap: _doubleTap,
                behavior: HitTestBehavior.translucent,
                child: TimeContainer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

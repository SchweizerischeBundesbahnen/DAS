import 'dart:async';
import 'package:flutter/material.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/main_container.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/time_container.dart';
import 'package:das_client/app/widgets/extended_header_container.dart';
import 'package:das_client/brightness/brightness_util.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Timer? _dimmingTimer;

  @override
  void dispose() {
    _dimmingTimer?.cancel();
    super.dispose();
  }

  void _startDimming() async {
    _dimmingTimer?.cancel();
    final value = await BrightnessUtil.getCurrentBrightness();
    final shouldDim = value >= 0.5;

    _dimmingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      final current = await BrightnessUtil.getCurrentBrightness();
      final newValue = shouldDim ? (current - 0.05).clamp(0.0, 1.0) : (current + 0.05).clamp(0.0, 1.0);
      await BrightnessUtil.setBrightness(newValue);
      if (newValue == 0.0 || newValue == 1.0) timer.cancel();
    });
  }

  void _stopDimming() {
    _dimmingTimer?.cancel();
  }

  void _doubleTap() async {
    final current = await BrightnessUtil.getCurrentBrightness();
    final newBrightness = current < 0.5 ? 1.0 : 0.1;
    await BrightnessUtil.setBrightness(newBrightness);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) async {
    double value = await BrightnessUtil.getCurrentBrightness();
    value += details.delta.dx > 0 ? 0.01 : -0.01;
    await BrightnessUtil.setBrightness(value.clamp(0.0, 1.0));
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) async {
    double value = await BrightnessUtil.getCurrentBrightness();
    value += details.delta.dy < 0 ? 0.01 : -0.01;
    await BrightnessUtil.setBrightness(value.clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedAppBarWrapper(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onVerticalDragUpdate: _onVerticalDragUpdate,
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

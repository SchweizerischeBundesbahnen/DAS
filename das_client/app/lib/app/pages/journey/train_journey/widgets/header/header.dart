import 'dart:async';

import 'package:app/app/pages/journey/train_journey/widgets/header/main_container.dart';
import 'package:app/app/pages/journey/train_journey/widgets/header/time_container.dart';
import 'package:app/app/widgets/extended_header_container.dart';
import 'package:app/brightness/brightness_manager.dart';
import 'package:app/brightness/brightness_modal_sheet.dart';
import 'package:app/di.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Timer? _dimmingTimer;
  final BrightnessManager _brightnessManager = DI.get<BrightnessManager>();

  final double maxBrightness = 1.0;
  final double minBrightness = 0.0;
  final double halfBrightness = 0.5;
  final double dimStep = 0.05;
  final double dragStep = 0.01;
  final int dimmingInterval = 50;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BrightnessModalSheet.openIfNeeded(context);
    });
  }

  void _startDimming() async {
    _dimmingTimer?.cancel();
    final value = await _brightnessManager.getCurrentBrightness();
    final shouldDim = value >= halfBrightness;

    _dimmingTimer = Timer.periodic(Duration(milliseconds: dimmingInterval), (timer) async {
      final current = await _brightnessManager.getCurrentBrightness();
      final newValue = shouldDim
          ? (current - dimStep).clamp(minBrightness, maxBrightness)
          : (current + dimStep).clamp(minBrightness, maxBrightness);
      await _brightnessManager.setBrightness(newValue);
      if (newValue == minBrightness || newValue == maxBrightness) timer.cancel();
    });
  }

  void _stopDimming() {
    _dimmingTimer?.cancel();
  }

  void _doubleTap() async {
    final current = await _brightnessManager.getCurrentBrightness();
    final newBrightness = current < halfBrightness ? maxBrightness : minBrightness;
    await _brightnessManager.setBrightness(newBrightness);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) async {
    double value = await _brightnessManager.getCurrentBrightness();
    value += details.delta.dx > 0 ? dragStep : -dragStep;
    await _brightnessManager.setBrightness(value.clamp(minBrightness, maxBrightness));
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
                child: const TimeContainer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

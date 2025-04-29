import 'dart:async';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/brightness/brightness_manager.dart';
import 'package:das_client/brightness/brightness_manager_impl.dart';
import 'package:das_client/brightness/permission_request_content.dart';
import 'package:das_client/di.dart';
import 'package:flutter/material.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/main_container.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/time_container.dart';
import 'package:das_client/app/widgets/extended_header_container.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:screen_brightness/screen_brightness.dart';

class Header extends StatefulWidget {
  const Header({
    super.key,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Timer? _dimmingTimer;
  final BrightnessManager _brightnessManager = DI.get<BrightnessManager>();

  @override
  void initState() {
    super.initState();
    _brightnessManager.setBrightness(1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openBrightnessModalIfNeeded();
    });
  }

  Future<void> _openBrightnessModalIfNeeded() async {
    final brightnessManager = BrightnessManagerImpl(ScreenBrightness());
    final hasPermission = await brightnessManager.hasWriteSettingsPermission();

    if (!hasPermission && mounted) {
      await showSBBModalSheet(
        context: context,
        title: context.l10n.w_modal_sheet_permissions_title,
        child: const PermissionRequestContent(),
      );
    }
  }

  void _startDimming() async {
    _dimmingTimer?.cancel();
    final value = await _brightnessManager.getCurrentBrightness();
    final shouldDim = value >= 0.5;

    _dimmingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      final current = await _brightnessManager.getCurrentBrightness();
      final newValue = shouldDim ? (current - 0.05).clamp(0.0, 1.0) : (current + 0.05).clamp(0.0, 1.0);
      await _brightnessManager.setBrightness(newValue);
      if (newValue == 0.0 || newValue == 1.0) timer.cancel();
    });
  }

  void _stopDimming() {
    _dimmingTimer?.cancel();
  }

  void _doubleTap() async {
    final current = await _brightnessManager.getCurrentBrightness();
    final newBrightness = current < 0.5 ? 1.0 : 0.1;
    await _brightnessManager.setBrightness(newBrightness);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) async {
    double value = await _brightnessManager.getCurrentBrightness();
    value += details.delta.dx > 0 ? 0.01 : -0.01;
    await _brightnessManager.setBrightness(value.clamp(0.0, 1.0));
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

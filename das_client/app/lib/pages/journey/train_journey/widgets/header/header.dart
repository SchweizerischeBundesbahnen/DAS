import 'package:app/brightness/brightness_manager.dart';
import 'package:app/brightness/brightness_modal_sheet.dart';
import 'package:app/di/di.dart';
import 'package:app/pages/journey/train_journey/train_journey_overview.dart';
import 'package:app/pages/journey/train_journey/widgets/header/das_chronograph.dart';
import 'package:app/pages/journey/train_journey/widgets/header/main_container.dart';
import 'package:app/widgets/extended_header_container.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final double maxBrightness = 1.0;
  final double minBrightness = 0.0;
  final double halfBrightness = 0.5;
  final double dragStep = 0.002;

  final BrightnessManager _brightnessManager = DI.get<BrightnessManager>();
  double? _dragBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BrightnessModalSheet.openIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedAppBarWrapper(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Padding(
          padding: const EdgeInsets.all(TrainJourneyOverview.horizontalPadding).copyWith(top: 0),
          child: Row(
            spacing: sbbDefaultSpacing * 0.5,
            children: [
              Expanded(child: MainContainer()),
              GestureDetector(
                onDoubleTap: _doubleTap,
                behavior: HitTestBehavior.translucent,
                child: const DASChronograph(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _doubleTap() async {
    final current = await _brightnessManager.getCurrentBrightness();
    final newBrightness = current < halfBrightness ? maxBrightness : minBrightness;
    await _brightnessManager.setBrightness(newBrightness);
  }

  void _onHorizontalDragStart(DragStartDetails details) async {
    _dragBrightness = await _brightnessManager.getCurrentBrightness();
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _dragBrightness = null;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) async {
    if (_dragBrightness == null) return;

    _dragBrightness = _dragBrightness! + (details.delta.dx * dragStep);
    _dragBrightness = _dragBrightness!.clamp(minBrightness, maxBrightness);

    await _brightnessManager.setBrightness(_dragBrightness!);
  }
}

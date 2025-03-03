import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/di.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BatteryStatus extends StatefulWidget {
  const BatteryStatus({super.key});

  @override
  State<BatteryStatus> createState() => _BatteryStatusState();

  static const Key batteryLevelLowIconKey = Key('batteryStatusLow');
}

class _BatteryStatusState extends State<BatteryStatus> {
  final Battery _battery = DI.get<Battery>();

  static const Duration batteryCheckInterval = Duration(minutes: 1);
  Timer? _batteryTimer;
  int? _batteryLevel;

  @override
  void initState() {
    super.initState();
    _setBatteryLevel();
    _startBatteryCheck();
  }

  void _startBatteryCheck() {
    _batteryTimer = Timer.periodic(batteryCheckInterval, (timer) {
      _setBatteryLevel();
    });
  }

  void _setBatteryLevel() {
    _battery.batteryLevel.then((level) => setState(() => _batteryLevel = level)).catchError((error) {
      Fimber.w('Battery is unavailable: $error');
    });
  }

  @override
  void dispose() {
    _batteryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _batteryLevel != null && _batteryLevel! <= 30
        ? SvgPicture.asset(
            key: BatteryStatus.batteryLevelLowIconKey,
            AppAssets.iconBatteryStatusLow,
          )
        : Container();
  }
}

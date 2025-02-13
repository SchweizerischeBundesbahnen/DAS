import 'dart:async';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/di.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:battery_plus/battery_plus.dart';

class BatteryStatus extends StatefulWidget {
  const BatteryStatus({super.key});

  @override
  State<BatteryStatus> createState() => _BatteryStatusState();
}

class _BatteryStatusState extends State<BatteryStatus> {
  final Battery _battery = DI.get<Battery>();
  static const Key batteryLevelLowIconKey = Key('battery_status_low_key');
  int? _batteryLevel;

  Timer? _batteryTimer;

  @override
  void initState() {
    super.initState();

    _battery.batteryLevel.then((level) => setState(() => _batteryLevel = level)).catchError((error) {
      Fimber.w('Battery is unavailable: $error');
    });

    _startBatteryCheck();
  }

  void _startBatteryCheck() {
    _batteryTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _battery.batteryLevel.then((level) {
        setState(() => _batteryLevel = level);
      }).catchError((error) {
        Fimber.w('Battery is unavailable: $error');
      });
    });
  }

  @override
  void dispose() {
    _batteryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _batteryLevel != null
        ? _batteryLevel! <= 30
            ? SvgPicture.asset(
                key: batteryLevelLowIconKey,
                AppAssets.iconBatteryStatusLow,
              )
            : Container()
        : Container();
  }
}

import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/widgets/assets.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logging/logging.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

final _log = Logger('BatteryStatus');

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
      _log.warning('Battery is unavailable: $error');
    });
  }

  @override
  void dispose() {
    _batteryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _batteryLevel != null && _batteryLevel! <= 15 ? _batteryIcon() : Container();
  }

  Widget _batteryIcon() {
    return GestureDetector(
      onTap: () => _openBatteryBottomSheet(context),
      child: SvgPicture.asset(
        key: BatteryStatus.batteryLevelLowIconKey,
        AppAssets.iconBatteryStatusLow,
      ),
    );
  }

  void _openBatteryBottomSheet(BuildContext context) async {
    await showSBBModalSheet(
      context: context,
      title: '',
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Padding(
        padding: const EdgeInsets.all(sbbDefaultSpacing),
        child: SBBMessage(
          title: context.l10n.w_modal_sheet_battery_status_battery_almost_empty,
          description: context.l10n.w_modal_sheet_battery_status_plug_in_device,
        ),
      ),
    );
  }
}

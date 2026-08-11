import 'dart:async';

import 'package:app/brightness/brightness_manager.dart';
import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/util/app_lifecycle_view_model.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BrightnessModalSheet extends StatefulWidget {
  const BrightnessModalSheet({super.key});

  static Future<void> openIfNeeded(BuildContext context) async {
    final brightnessManager = DI.get<BrightnessManager>();
    final hasPermission = await brightnessManager.hasWriteSettingsPermission();

    if (!hasPermission && context.mounted) {
      await showSBBBottomSheet(
        context: context,
        titleText: context.l10n.w_modal_sheet_permissions_title,
        body: const BrightnessModalSheet(),
      );
    }
  }

  @override
  State<BrightnessModalSheet> createState() => _BrightnessModalSheetState();
}

class _BrightnessModalSheetState extends State<BrightnessModalSheet> {
  StreamSubscription<void>? _onResumedSubscription;

  @override
  void initState() {
    super.initState();
    _onResumedSubscription = DI.get<AppLifecycleViewModel>().onResumed.listen((_) => _closeIfPermissionGranted());
  }

  @override
  void dispose() {
    _onResumedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _closeIfPermissionGranted() async {
    final brightnessManager = DI.get<BrightnessManager>();
    final hasPermission = await brightnessManager.hasWriteSettingsPermission();

    if (hasPermission && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      spacing: SBBSpacing.large,
      children: [
        Text(
          context.l10n.w_modal_sheet_permission_brightness,
          style: sbbTextStyle.romanStyle.medium,
        ),
        SBBPrimaryButton(
          labelText: context.l10n.w_modal_sheet_button_grant_permission,
          onPressed: () async {
            final brightnessManager = DI.get<BrightnessManager>();
            await brightnessManager.requestWriteSettings();
          },
        ),
      ],
    );
  }
}

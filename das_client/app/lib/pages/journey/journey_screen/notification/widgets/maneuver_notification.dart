import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/view_model/warn_app_view_model.dart';
import 'package:app/widgets/das_icons.dart';
import 'package:app/widgets/notificationbox/notification_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ManeuverNotification extends StatelessWidget {
  static const Key openWaraAppButtonKey = Key('openWaraAppButton');
  static const Key maneuverNotificationSwitchKey = Key('maneuverNotificationSwitch');

  const ManeuverNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<WarnAppViewModel>();

    return StreamBuilder(
      stream: viewModel.isManeuverModeEnabled,
      builder: (context, snapshot) {
        final isManeuverModeEnabled = snapshot.data ?? false;
        if (!isManeuverModeEnabled) return SizedBox.shrink();

        return NotificationBox(
          style: .warning,
          title: context.l10n.w_maneuver_notification_text,
          action: Row(
            children: [
              _openWaraButton(viewModel),
              Text(context.l10n.w_maneuver_notification_maneuver, style: sbbTextStyle.lightStyle.medium),
              const SizedBox(width: SBBSpacing.xSmall),
              SBBSwitch(
                key: maneuverNotificationSwitchKey,
                value: isManeuverModeEnabled,
                onChanged: (value) => viewModel.setManeuverMode(value),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _openWaraButton(WarnAppViewModel viewModel) {
    return FutureBuilder(
      future: viewModel.isWaraAppInstalled,
      builder: (context, snapshot) {
        final isWaraAppInstalled = snapshot.data ?? false;
        if (!isWaraAppInstalled) return SizedBox.shrink();

        return Padding(
          padding: const .only(right: SBBSpacing.medium),
          child: SBBTertiaryButtonSmall(
            key: openWaraAppButtonKey,
            icon: DasIcons.appIconWarnfunktionRangier,
            label: context.l10n.w_maneuver_notification_wara_action,
            onPressed: () => viewModel.openWaraApp(),
          ),
        );
      },
    );
  }
}

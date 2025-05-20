import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:app/widgets/das_icons.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/notificationbox/notification_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ManeuverNotification extends StatelessWidget {
  static const Key maneuverNotificationSwitchKey = Key('maneuverNotificationSwitch');

  const ManeuverNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<TrainJourneyViewModel>();

    return StreamBuilder<TrainJourneySettings>(
      stream: viewModel.settings,
      builder: (context, snapshot) {
        final showNotification = snapshot.data?.isManeuverModeEnabled ?? false;
        if (!showNotification) return SizedBox.shrink();

        return Container(
          margin: EdgeInsets.fromLTRB(sbbDefaultSpacing * 0.5, 0, sbbDefaultSpacing * 0.5, sbbDefaultSpacing * 0.5),
          child: NotificationBox(
            style: NotificationBoxStyle.warning,
            text: context.l10n.w_maneuver_notification_text,
            action: Row(
              children: [
                SBBTertiaryButtonSmall(
                  icon: DasIcons.appIconWarnfunktionRangier,
                  label: context.l10n.w_maneuver_notification_wara_action,
                  onPressed: () {
                    // TODO open Wara
                  },
                ),
                const SizedBox(width: sbbDefaultSpacing),
                Text(context.l10n.w_maneuver_notification_maneuver, style: DASTextStyles.mediumLight),
                const SizedBox(width: sbbDefaultSpacing * 0.5),
                SBBSwitch(
                  key: maneuverNotificationSwitchKey,
                  value: snapshot.data?.isManeuverModeEnabled ?? false,
                  onChanged: (value) => viewModel.setManeuverMode(value),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

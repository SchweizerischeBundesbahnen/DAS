import 'package:app/app/bloc/train_journey_cubit.dart';
import 'package:app/app/i18n/i18n.dart';
import 'package:app/app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/app/widgets/das_icons.dart';
import 'package:app/app/widgets/das_text_styles.dart';
import 'package:app/app/widgets/notificationbox/notification_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ManeuverNotification extends StatelessWidget {
  static const Key maneuverNotificationSwitchKey = Key('maneuverNotificationSwitch');

  const ManeuverNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final trainJourneyCubit = context.read<TrainJourneyCubit>();

    return StreamBuilder<TrainJourneySettings>(
      stream: trainJourneyCubit.settingsStream,
      builder: (context, snapshot) {
        final showNotification = snapshot.data?.maneuverMode ?? false;

        return showNotification
            ? Container(
                margin:
                    EdgeInsets.fromLTRB(sbbDefaultSpacing * 0.5, 0, sbbDefaultSpacing * 0.5, sbbDefaultSpacing * 0.5),
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
                          value: snapshot.data?.maneuverMode ?? false,
                          onChanged: (value) => trainJourneyCubit.setManeuverMode(value)),
                    ],
                  ),
                ),
              )
            : Container();
      },
    );
  }
}

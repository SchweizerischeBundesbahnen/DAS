import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/disturbance_view_modal.dart';
import 'package:app/pages/journey/journey_table/journey_overview.dart';
import 'package:app/widgets/notificationbox/notification_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class DisturbanceNotification extends StatelessWidget {
  static const Key disturbanceNotificationKey = Key('disturbanceNotification');

  const DisturbanceNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<DisturbanceViewModal>();

    return StreamBuilder(
      stream: viewModel.disturbanceStream,
      builder: (context, snapshot) {
        final disturbanceType = snapshot.data ?? false;
        if (disturbanceType != DisturbanceEventType.start) return SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(JourneyOverview.horizontalPadding).copyWith(top: 0),
          child: NotificationBox(
            style: .warning,
            title: context.l10n.w_disturbance_notification_text,
            customIcon: SBBIcons.arrow_circle_lightning_small,
            key: disturbanceNotificationKey,
          ),
        );
      },
    );
  }
}

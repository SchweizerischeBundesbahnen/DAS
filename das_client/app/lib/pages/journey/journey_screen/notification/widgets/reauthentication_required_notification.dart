import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/view_model/reauthentication_required_view_model.dart';
import 'package:app/widgets/notificationbox/notification_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ReauthenticationRequiredNotification extends StatelessWidget {
  const ReauthenticationRequiredNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationBox(
      style: .information,
      title: context.l10n.w_reauthentication_required_notification_text,
      action: SBBTertiaryButtonSmall(
        labelText: context.l10n.w_reauthentication_required_notification_button,
        onPressed: () => context.read<ReauthenticationRequiredViewModel>().reauthenticate(),
      ),
    );
  }
}

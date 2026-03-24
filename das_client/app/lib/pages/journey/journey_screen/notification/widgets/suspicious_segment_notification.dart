import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/model/suspicious_segment_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/suspicious_segment_view_model.dart';
import 'package:app/widgets/notificationbox/notification_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class SuspiciousSegmentNotification extends StatelessWidget {
  static const Key suspiciousSegmentNotificationKey = Key('suspiciousSegmentNotification');
  static const Key dismissKey = Key('suspiciousSegmentNotificationDismiss');

  const SuspiciousSegmentNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<SuspiciousSegmentViewModel>();

    return StreamBuilder<SuspiciousSegmentModel>(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final model = snapshot.data;
        if (model is! SuspiciousSegmentVisible) return SizedBox.shrink();

        return NotificationBox(
          key: suspiciousSegmentNotificationKey,
          style: .warning,
          titleTextStyle: SBBTextStyles.smallLight,
          title: context.l10n.w_suspicious_segment_notification_text,
          customIcon: SBBIcons.circle_exclamation_point_small,
          action: InkWell(
            key: dismissKey,
            onTap: viewModel.dismiss,
            radius: SBBSpacing.large,
            borderRadius: BorderRadius.circular(SBBSpacing.large),
            child: Padding(
              padding: const .all(SBBSpacing.xxSmall),
              child: Icon(SBBIcons.cross_tiny_small),
            ),
          ),
        );
      },
    );
  }
}

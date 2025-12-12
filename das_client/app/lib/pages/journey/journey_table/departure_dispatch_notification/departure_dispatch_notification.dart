import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_table/departure_dispatch_notification/departure_dispatch_notification_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class DepartureDispatchNotification extends StatelessWidget {
  static const Key departureDispatchNotificationKey = Key('departureDispatchNotification');

  const DepartureDispatchNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<DepartureDispatchNotificationViewModel>();

    return StreamBuilder(
      stream: viewModel.type,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        return _notification(context, type: snapshot.data!);
      },
    );
  }

  Widget _notification(BuildContext context, {required DepartureDispatchNotificationType type}) {
    final resolvedBackgroundColor = ThemeUtil.getColor(context, SBBColors.iron, SBBColors.platinum);
    final resolvedForegroundColor = ThemeUtil.getColor(context, SBBColors.white, SBBColors.black);

    return Container(
      key: departureDispatchNotificationKey,
      margin: const EdgeInsets.all(sbbDefaultSpacing * 0.5).copyWith(top: 0),
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: BorderRadius.circular(sbbDefaultSpacing),
      ),
      constraints: BoxConstraints(minHeight: 54.0),
      padding: .only(left: 22.0),
      child: Align(
        alignment: .centerLeft,
        child: Row(
          spacing: sbbDefaultSpacing * 0.5,
          children: [
            Icon(SBBIcons.clock_small, color: resolvedForegroundColor),
            Text(
              type.toLocalized(context),
              style: DASTextStyles.largeBold.copyWith(color: resolvedForegroundColor),
            ),
          ],
        ),
      ),
    );
  }
}

extension _DepartureDispatchNotificationTypeExtension on DepartureDispatchNotificationType {
  String toLocalized(BuildContext context) => switch (this) {
    .prepareForDepartureLong => context.l10n.w_departure_dispatch_notification_long,
    .prepareForDepartureMiddle => context.l10n.w_departure_dispatch_notification_middle,
    .prepareForDepartureShort => context.l10n.w_departure_dispatch_notification_short,
    .prepareForDeparture => context.l10n.w_departure_dispatch_notification_prepare,
    .departureProvisionWithdrawn => context.l10n.w_departure_dispatch_notification_withdrawn,
  };
}

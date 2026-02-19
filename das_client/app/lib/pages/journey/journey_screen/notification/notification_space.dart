import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/notification/notification_type.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/advised_speed_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/break_load_slip_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/departure_dispatch_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/disturbance_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/koa_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/maneuver_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/replacement_series_notification.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/ux_testing_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/warn_function_modal_sheet.dart';
import 'package:app/pages/journey/view_model/warn_app_view_model.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:app/widgets/stream_listener.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class NotificationSpace extends StatelessWidget {
  const NotificationSpace({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationPriorityVM = context.read<NotificationPriorityQueueViewModel>();

    return StreamListener(
      stream: context.read<WarnAppViewModel>().warnappEvents,
      onData: (data) {
        _triggerWarnappNotification(context);
      },
      child: StreamListener(
        stream: context.read<UxTestingViewModel>().uxTestingEvents,
        onData: (data) {
          if (data.isWarn) {
            _triggerWarnappNotification(context);
          }
        },
        child: StreamBuilder(
          stream: notificationPriorityVM.model,
          initialData: notificationPriorityVM.modelValue,
          builder: (context, asyncSnapshot) {
            final data = asyncSnapshot.requireData;
            if (data.isEmpty) return SizedBox.shrink();
            if (data.length == 1) return data.first.toWidget();

            return Column(
              mainAxisSize: .min,
              spacing: SBBSpacing.xSmall,
              children: data.map((notification) => notification.toWidget()).toList(growable: false),
            );
          },
        ),
      ),
    );
  }

  void _triggerWarnappNotification(BuildContext context) {
    DI.get<DASSounds>().warnApp.play();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showWarnFunctionModalSheet(
        context,
        onManeuverButtonPressed: () => context.read<WarnAppViewModel>().setManeuverMode(true),
      );
    });
  }
}

extension _WidgetNotificationTypeX on NotificationType {
  Widget toWidget() {
    return switch (this) {
      .illegalSegmentNoReplacement => ReplacementSeriesNotification(),
      .koaWait => KoaNotification(),
      .koaWaitCancelled => KoaNotification(),
      .newBreakLoadSlip => BreakLoadSlipNotification(),
      .maneuverMode => ManeuverNotification(),
      .disturbance => DisturbanceNotification(),
      .advisedSpeed => AdvisedSpeedNotification(),
      .departureDispatch => DepartureDispatchNotification(),
      .illegalSegmentWithReplacement => ReplacementSeriesNotification(),
    };
  }
}

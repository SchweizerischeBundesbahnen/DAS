import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/journey_overview.dart';
import 'package:app/pages/journey/journey_screen/notification/notification_type.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/advised_speed_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/brake_load_slip_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/customer_oriented_departure_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/departure_dispatch_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/disturbance_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/maneuver_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/reauthentication_required_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/replacement_series_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/suspicious_segment_notification.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/ux_testing_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/warn_function_modal_sheet.dart';
import 'package:app/pages/journey/view_model/warn_app_view_model.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:app/util/animation.dart';
import 'package:app/widgets/stream_listener.dart';
import 'package:collection/collection.dart';
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

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: JourneyOverview.horizontalPadding),
              child: Column(
                mainAxisSize: .min,
                children: [
                  const SizedBox(height: SBBSpacing.xSmall),
                  _AnimatedNotificationSlot(type: data.elementAtOrNull(0)),
                  _AnimatedNotificationSlot(type: data.elementAtOrNull(1)),
                ],
              ),
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

/// Animates the notification of a single slot in [NotificationSpace].
///
/// Appearing ([type] set) fades and grows the notification in, disappearing ([type] null) fades and
/// collapses it. Replacing one notification with another cross-fades while the size transitions
/// directly between the two heights, keeping the occupied space instead of collapsing it.
class _AnimatedNotificationSlot extends StatelessWidget {
  const _AnimatedNotificationSlot({required this.type});

  final NotificationType? type;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: DASAnimation.mediumDuration,
      curve: Curves.easeInOutCubicEmphasized,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: DASAnimation.mediumDuration,
        switchInCurve: Curves.easeInOutCubicEmphasized,
        switchOutCurve: Curves.easeInOutCubicEmphasized,
        layoutBuilder: (currentChild, previousChildren) => Stack(
          alignment: Alignment.topCenter,
          children: [...previousChildren, ?currentChild],
        ),
        child: type == null
            ? const SizedBox(key: ValueKey('emptyNotificationSlot'), width: double.infinity)
            : Padding(
                key: ValueKey(type),
                padding: const EdgeInsets.only(bottom: SBBSpacing.xSmall),
                child: type!.toWidget(),
              ),
      ),
    );
  }
}

extension _WidgetNotificationTypeX on NotificationType {
  Widget toWidget() {
    return switch (this) {
      .illegalSegmentNoReplacement => ReplacementSeriesNotification(),
      .customerOrientedDeparture => CustomerOrientedDepartureNotification(),
      .newBrakeLoadSlip => BrakeLoadSlipNotification(),
      .maneuverMode => ManeuverNotification(),
      .disturbance => DisturbanceNotification(),
      .advisedSpeed => AdvisedSpeedNotification(),
      .departureDispatch => DepartureDispatchNotification(),
      .illegalSegmentWithReplacement => ReplacementSeriesNotification(),
      .suspiciousSegment => SuspiciousSegmentNotification(),
      .reauthenticationRequired => ReauthenticationRequiredNotification(),
    };
  }
}

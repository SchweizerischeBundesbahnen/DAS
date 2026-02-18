import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/advised_speed_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/break_load_slip_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/departure_dispatch_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/disturbance_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/koa_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/maneuver_notification.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/replacement_series_notification.dart';
import 'package:app/pages/journey/journey_screen/view_model/ux_testing_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/warn_function_modal_sheet.dart';
import 'package:app/pages/journey/view_model/warn_app_view_model.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:app/widgets/stream_listener.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class NotificationSpace extends StatelessWidget {
  const NotificationSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        AdvisedSpeedNotification(),
        ManeuverNotification(),
        KoaNotification(),
        ReplacementSeriesNotification(),
        DepartureDispatchNotification(),
        _warnAppNotification(context),
        BreakLoadSlipNotification(),
        DisturbanceNotification(),
        _uxTestingEventListener(context),
      ],
    );
  }

  Widget _warnAppNotification(BuildContext context) {
    return StreamListener(
      stream: context.read<WarnAppViewModel>().warnappEvents,
      onData: (data) {
        _triggerWarnappNotification(context);
      },
    );
  }

  Widget _uxTestingEventListener(BuildContext context) {
    return StreamListener(
      stream: context.read<UxTestingViewModel>().uxTestingEvents,
      onData: (data) {
        if (data.isWarn) {
          _triggerWarnappNotification(context);
        }
      },
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

import 'package:app/pages/journey/train_journey/header/radio_channel/radio_channel_view_model.dart';
import 'package:app/pages/journey/train_journey/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/header/battery_status.dart';
import 'package:app/pages/journey/train_journey/widgets/header/connectivity_icon.dart';
import 'package:app/pages/journey/train_journey/widgets/header/departure_authorization.dart';
import 'package:app/pages/journey/train_journey/widgets/header/extended_menu.dart';
import 'package:app/pages/journey/train_journey/widgets/header/journey_identifier.dart';
import 'package:app/pages/journey/train_journey/widgets/header/journey_search_overlay.dart';
import 'package:app/pages/journey/train_journey/widgets/header/next_stop.dart';
import 'package:app/pages/journey/train_journey/widgets/header/radio_channel.dart';
import 'package:app/pages/journey/train_journey/widgets/header/start_pause_button.dart';
import 'package:app/pages/journey/train_journey/widgets/header/theme_button.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class MainContainer extends StatelessWidget {
  const MainContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final journeyViewModel = context.read<TrainJourneyViewModel>();
    final journeyPositionViewModel = context.read<JourneyPositionViewModel>();

    return Provider<RadioChannelViewModel>(
      create: (_) => RadioChannelViewModel(
        journeyStream: journeyViewModel.journey,
        journeyPositionStream: journeyPositionViewModel.model,
      ),
      dispose: (_, vm) => vm.dispose(),
      child: SBBGroup(
        padding: const EdgeInsets.all(sbbDefaultSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _topHeaderRow(),
            _divider(),
            _bottomHeaderRow(),
          ],
        ),
      ),
    );
  }

  Widget _bottomHeaderRow() => SizedBox(
    height: 48.0,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RadioChannel(),
        SizedBox(width: sbbDefaultSpacing * 0.5),
        DepartureAuthorization(),
        Spacer(),
        JourneyIdentifier(),
        BatteryStatus(),
        ConnectivityIcon(),
      ],
    ),
  );

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.5),
    child: Divider(height: 1.0, color: SBBColors.cloud),
  );

  Widget _topHeaderRow() => SizedBox(
    height: 48.0,
    child: Row(
      children: [
        Expanded(child: NextStop()),
        _buttons(),
      ],
    ),
  );

  Widget _buttons() => Row(
    spacing: sbbDefaultSpacing * 0.5,
    children: [
      ThemeButton(),
      StartPauseButton(),
      ExtendedMenu(),
      JourneySearchOverlay(),
    ],
  );
}

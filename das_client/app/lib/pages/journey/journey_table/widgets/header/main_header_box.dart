import 'package:app/pages/journey/journey_table/widgets/header/battery_status.dart';
import 'package:app/pages/journey/journey_table/widgets/header/break_slip_button.dart';
import 'package:app/pages/journey/journey_table/widgets/header/connectivity_icon.dart';
import 'package:app/pages/journey/journey_table/widgets/header/departure_authorization_display.dart';
import 'package:app/pages/journey/journey_table/widgets/header/extended_menu.dart';
import 'package:app/pages/journey/journey_table/widgets/header/journey_advancement_button.dart';
import 'package:app/pages/journey/journey_table/widgets/header/next_stop.dart';
import 'package:app/pages/journey/journey_table/widgets/header/theme_button.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MainHeaderBox extends StatelessWidget {
  const MainHeaderBox({super.key});

  @override
  Widget build(BuildContext context) {
    final journeyViewModel = context.read<JourneyTableViewModel>();

    return StreamBuilder(
      stream: journeyViewModel.journey,
      builder: (context, snapshot) {
        final isLoading = !snapshot.hasData;
        return Skeletonizer(
          enabled: isLoading,
          child: _content(),
        );
      },
    );
  }

  Widget _content() {
    return SBBGroup(
      padding: const .all(sbbDefaultSpacing),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          _topHeaderRow(),
          _divider(),
          _bottomHeaderRow(),
        ],
      ),
    );
  }

  Widget _bottomHeaderRow() => SizedBox(
    height: 48.0,
    child: Row(
      crossAxisAlignment: .center,
      children: [
        NextStop(),
        Spacer(),
        DepartureAuthorizationDisplay(),
      ],
    ),
  );

  Widget _divider() => const Padding(
    padding: .symmetric(vertical: sbbDefaultSpacing * 0.5),
    child: Divider(height: 1.0, color: SBBColors.cloud),
  );

  Widget _topHeaderRow() => SizedBox(
    height: 48.0,
    child: Row(
      children: [
        BatteryStatus(),
        ConnectivityIcon(),
        Spacer(),
        _buttons(),
      ],
    ),
  );

  Widget _buttons() => Row(
    spacing: sbbDefaultSpacing * 0.5,
    children: [
      // marked as leaf as default draws a border
      Skeleton.leaf(child: BreakSlipButton()),
      Skeleton.leaf(child: ThemeButton()),
      Skeleton.leaf(child: JourneyAdvancementButton()),
      ExtendedMenu(),
    ],
  );
}

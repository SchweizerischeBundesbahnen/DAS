import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/departure_authorization.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/radio_channel.dart';
import 'package:das_client/app/widgets/widget_extensions.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class MainContainer extends StatelessWidget {
  const MainContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      margin: const EdgeInsetsDirectional.fromSTEB(
        sbbDefaultSpacing * 0.5,
        0,
        sbbDefaultSpacing * 0.5,
        sbbDefaultSpacing,
      ),
      padding: const EdgeInsets.all(sbbDefaultSpacing),
      useShadow: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _topHeaderRow(),
          _divider(),
          _bottomHeaderRow(),
        ],
      ),
    );
  }

  Widget _bottomHeaderRow() {
    return const SizedBox(
      height: 48.0,
      child: Row(
        children: [
          RadioChannel(),
          SizedBox(width: 48.0),
          DepartureAuthorization(),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.5),
      child: Divider(height: 1.0, color: SBBColors.cloud),
    );
  }

  Widget _topHeaderRow() {
    return SizedBox(
      height: 48.0,
      child: Row(
        children: [
          // TODO: Replace with custom icon from figma
          const Icon(SBBIcons.route_circle_end_small),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: sbbDefaultSpacing * 0.5),
              child: Text('Brugg', style: SBBTextStyles.largeLight.copyWith(fontSize: 24.0)),
            ),
          ),
          _buttonArea(),
        ],
      ),
    );
  }

  Widget _buttonArea() {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            SBBTertiaryButtonLarge(
              label: context.l10n.p_train_journey_header_button_dark_theme,
              icon: SBBIcons.moon_small,
              onPressed: () {},
            ),
            SBBTertiaryButtonLarge(
              label: context.l10n.p_train_journey_header_button_pause,
              icon: SBBIcons.pause_small,
              onPressed: () {},
            ),
            SBBIconButtonLarge(
              icon: SBBIcons.context_menu_small,
              onPressed: () {},
            ),
          ].withSpacing(width: sbbDefaultSpacing * 0.5),
        );
      }
    );
  }
}

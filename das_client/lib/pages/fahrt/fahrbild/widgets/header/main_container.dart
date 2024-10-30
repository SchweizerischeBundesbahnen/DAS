import 'package:das_client/pages/fahrt/fahrbild/widgets/header/abfahrtserlaubnis.dart';
import 'package:das_client/pages/fahrt/fahrbild/widgets/header/radio_channel.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class MainContainer extends StatelessWidget {
  const MainContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      margin: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 16),
      padding: const EdgeInsets.all(16),
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
          Abfahrtserlaubnis(),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
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
              padding: const EdgeInsets.only(left: 8.0),
              child: Text('Brugg',
                  style: SBBTextStyles.largeLight.copyWith(fontSize: 24.0)),
            ),
          ),
          _buttonArea(),
        ],
      ),
    );
  }

  Widget _buttonArea() {
    return Row(
      children: [
        SBBTertiaryButtonLarge(
          label: 'Nachtmodus',
          icon: SBBIcons.moon_small,
          onPressed: () {},
        ),
        SBBTertiaryButtonLarge(
          label: 'Pause',
          icon: SBBIcons.pause_small,
          onPressed: () {},
        ),
        SBBIconButtonLarge(
          icon: SBBIcons.context_menu_small,
          onPressed: () {},
        ),
      ].withSpacing(8.0),
    );
  }
}

// extensions

extension _Spacing on List<Widget> {
  withSpacing(double width) {
    return expand((x) => [SizedBox(width: width), x]).skip(1).toList();
  }
}

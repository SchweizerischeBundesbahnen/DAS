import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class ButtonArea extends StatelessWidget {
  const ButtonArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SBBTertiaryButtonLarge(label: 'Button', onPressed: () {}),
        SBBIconButtonLarge(icon: SBBIcons.tick_small, onPressed: () {}),
        SBBIconButtonLarge(icon: SBBIcons.context_menu_small, onPressed: () {}),
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

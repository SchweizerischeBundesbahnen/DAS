import 'package:app/app/i18n/i18n.dart';
import 'package:app/app/pages/journey/train_journey/widgets/header/animated_header_icon_button.dart';
import 'package:app/theme/theme_provider.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeUtil.isDarkMode(context);
    return AnimatedHeaderIconButton(
      label: isDarkMode
          ? context.l10n.p_train_journey_header_button_light_theme
          : context.l10n.p_train_journey_header_button_dark_theme,
      icon: isDarkMode ? SBBIcons.sunshine_small : SBBIcons.moon_small,
      onPressed: () {
        final themeManager = context.read<ThemeProvider>();
        themeManager.toggleTheme(context);
      },
    );
  }
}

import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class HeaderIconButton extends StatelessWidget {
  static const headerIconButtonKey = Key('headerIconButton');
  static const headerIconWithLabelButtonKey = Key('headerIconWithLabelButton');

  const HeaderIconButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.invertColors = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool invertColors;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<DetailModalViewModel>();
    return StreamBuilder(
      initialData: viewModel.isModalOpenValue,
      stream: viewModel.isModalOpen,
      builder: (context, snapshot) {
        final isDetailModalSheetOpen = snapshot.requireData;

        ButtonStyle? buttonStyle;
        if (invertColors) buttonStyle = _invertButtonStyle(context);

        return isDetailModalSheetOpen ? _iconButton(buttonStyle) : _iconWithLabelButton(buttonStyle, context);
      },
    );
  }

  Widget _iconWithLabelButton(ButtonStyle? buttonStyle, BuildContext context) {
    final button = SBBTertiaryButtonLarge(
      key: headerIconWithLabelButtonKey,
      label: label,
      icon: icon,
      onPressed: onPressed,
    );
    if (buttonStyle == null) return button;

    final themeData = Theme.of(context);
    return Theme(
      data: themeData.copyWith(textButtonTheme: TextButtonThemeData(style: buttonStyle)),
      child: button,
    );
  }

  Widget _iconButton(ButtonStyle? buttonStyle) {
    /// ThemeData & ButtonStyle is weirdly overwritten in Design System
    /// Will be changed with https://github.com/SchweizerischeBundesbahnen/design_system_flutter/pull/425
    /// and v5.0.0 is released
    final iconStyle = buttonStyle?.copyWith(padding: WidgetStatePropertyAll(EdgeInsets.zero));
    return SBBIconButtonLarge(
      key: headerIconButtonKey,
      icon: icon,
      onPressed: onPressed,
      buttonStyle: iconStyle,
    );
  }

  ButtonStyle? _invertButtonStyle(BuildContext context) {
    final baseStyle = Theme.of(context).textButtonTheme.style;
    return baseStyle?.copyWith(
      backgroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color>{
        WidgetState.pressed | WidgetState.focused: ThemeUtil.getColor(
          context,
          SBBColors.charcoal,
          SBBColors.platinum,
        ),
        WidgetState.any: ThemeUtil.getColor(context, SBBColors.anthracite, SBBColors.silver),
      }),
      foregroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color>{
        WidgetState.any: ThemeUtil.getColor(context, SBBColors.white, SBBColors.black),
      }),
      iconColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color>{
        WidgetState.any: ThemeUtil.getColor(context, SBBColors.white, SBBColors.black),
      }),
    );
  }
}

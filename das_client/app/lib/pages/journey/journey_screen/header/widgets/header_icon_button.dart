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

        return SBBTertiaryButton(
          key: headerIconWithLabelButtonKey,
          labelText: isDetailModalSheetOpen ? null : label,
          iconData: icon,
          onPressed: onPressed,
          style: invertColors ? _invertButtonStyle(context) : null,
        );
      },
    );
  }

  SBBButtonStyle? _invertButtonStyle(BuildContext context) {
    return SBBButtonStyle(
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

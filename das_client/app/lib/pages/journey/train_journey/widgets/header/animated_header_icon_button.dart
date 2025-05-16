import 'package:app/pages/journey/train_journey/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class AnimatedHeaderIconButton extends StatelessWidget {
  static const headerIconButtonKey = Key('headerIconButton');
  static const headerIconWithLabelButtonKey = Key('headerIconWithLabelButton');

  const AnimatedHeaderIconButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<DetailModalViewModel>();
    return StreamBuilder<bool>(
      initialData: viewModel.isModalOpenValue,
      stream: viewModel.isModalOpen,
      builder: (context, snapshot) {
        final isDetailModalSheetOpen = snapshot.requireData;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: isDetailModalSheetOpen ? _iconButton : _iconWithLabelButton,
        );
      },
    );
  }

  Widget get _iconWithLabelButton =>
      SBBTertiaryButtonLarge(key: headerIconWithLabelButtonKey, label: label, icon: icon, onPressed: onPressed);

  Widget get _iconButton => SBBIconButtonLarge(key: headerIconButtonKey, icon: icon, onPressed: onPressed);
}

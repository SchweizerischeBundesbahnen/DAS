import 'package:app/di/di.dart';
import 'package:app/pages/journey/navigation/journey_navigation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneyNavigationButtons extends StatefulWidget {
  const JourneyNavigationButtons({super.key});

  @override
  State<JourneyNavigationButtons> createState() => _JourneyNavigationButtonsState();
}

class _JourneyNavigationButtonsState extends State<JourneyNavigationButtons> {
  @override
  Widget build(BuildContext context) {
    final viewModel = DI.get<JourneyNavigationViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final snap = snapshot.data;
        if (snap == null || !snap.showNavigationButtons) return SizedBox.shrink();

        final isDark = Theme.brightnessOf(context) == Brightness.dark;

        return Container(
          margin: EdgeInsets.only(bottom: sbbDefaultSpacing * 2),
          padding: EdgeInsets.all(sbbDefaultSpacing / 2),
          decoration: ShapeDecoration(
            shape: StadiumBorder(),
            color: isDark ? SBBColors.granite : SBBColors.milk,
            shadows: [
              BoxShadow(
                blurRadius: sbbDefaultSpacing / 2,
                color: isDark ? SBBColors.white.withValues(alpha: .4) : SBBColors.black.withValues(alpha: .2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SBBIconButtonLarge(icon: SBBIcons.chevron_left_small, onPressed: () => viewModel.previous()),
              SizedBox(width: sbbDefaultSpacing),
              SBBPagination(numberPages: snap.navigationStackLength, currentPage: snap.currentIndex),
              SizedBox(width: sbbDefaultSpacing),
              SBBIconButtonLarge(icon: SBBIcons.chevron_right_small, onPressed: () => viewModel.next()),
            ],
          ),
        );
      },
    );
  }
}

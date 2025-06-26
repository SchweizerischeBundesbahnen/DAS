import 'package:app/di/di.dart';
import 'package:app/pages/journey/navigation/journey_navigation_model.dart';
import 'package:app/pages/journey/navigation/journey_navigation_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

const _animationDuration = Duration(milliseconds: 300);

class JourneyNavigationButtons extends StatelessWidget {
  static const Key journeyNavigationButtonKey = Key('JourneyNavigationButtons');
  static const Key journeyNavigationButtonPreviousKey = Key('JourneyNavigationButtonsPreviousButton');
  static const Key journeyNavigationButtonNextKey = Key('JourneyNavigationButtonsNextButton');

  const JourneyNavigationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationVM = DI.get<JourneyNavigationViewModel>();
    final journeyVM = context.read<TrainJourneyViewModel>();
    return StreamBuilder(
      stream: CombineLatestStream.list([navigationVM.model, journeyVM.settings]),
      initialData: [navigationVM.modelValue, journeyVM.settingsValue],
      builder: (context, snapshot) {
        final snap = snapshot.data;
        if (snap == null || snap[0] == null || snap[1] == null) return SizedBox.shrink();

        final navigationModel = snap[0] as JourneyNavigationModel;
        final settings = snap[1] as TrainJourneySettings;

        if (!navigationModel.showNavigationButtons) return SizedBox.shrink();

        final resolvedShowNavButtons = navigationModel.showNavigationButtons && !settings.isAutoAdvancementEnabled;

        return AnimatedOpacity(
          opacity: resolvedShowNavButtons ? 1.0 : 0.0,
          duration: _animationDuration,
          child: IgnorePointer(
            ignoring: !resolvedShowNavButtons,
            child: Container(
              key: journeyNavigationButtonKey,
              margin: EdgeInsets.only(bottom: sbbDefaultSpacing * 2),
              padding: EdgeInsets.all(sbbDefaultSpacing / 2),
              decoration: _navigationButtonsDecoration(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SBBIconButtonLarge(
                    key: journeyNavigationButtonPreviousKey,
                    icon: SBBIcons.chevron_left_small,
                    onPressed: () => navigationVM.previous(),
                  ),
                  SizedBox(width: sbbDefaultSpacing),
                  SBBPagination(
                    numberPages: navigationModel.navigationStackLength,
                    currentPage: navigationModel.currentIndex,
                  ),
                  SizedBox(width: sbbDefaultSpacing),
                  SBBIconButtonLarge(
                    key: journeyNavigationButtonNextKey,
                    icon: SBBIcons.chevron_right_small,
                    onPressed: () => navigationVM.next(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ShapeDecoration _navigationButtonsDecoration(BuildContext context) {
    final isDark = Theme.brightnessOf(context) == Brightness.dark;
    return ShapeDecoration(
      shape: StadiumBorder(),
      color: isDark ? SBBColors.granite : SBBColors.milk,
      shadows: [
        BoxShadow(
          blurRadius: sbbDefaultSpacing / 2,
          color: isDark ? SBBColors.white.withValues(alpha: .4) : SBBColors.black.withValues(alpha: .2),
        ),
      ],
    );
  }
}

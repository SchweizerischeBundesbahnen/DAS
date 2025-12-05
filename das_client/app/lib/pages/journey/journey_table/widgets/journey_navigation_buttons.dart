import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_table/widgets/table/config/journey_settings.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:app/pages/journey/navigation/journey_navigation_model.dart';
import 'package:app/pages/journey/navigation/journey_navigation_view_model.dart';
import 'package:app/widgets/navigation_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

const _animationDuration = Duration(milliseconds: 300);

class JourneyNavigationButtons extends StatelessWidget {
  const JourneyNavigationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationVM = DI.get<JourneyNavigationViewModel>();
    final journeyVM = context.read<JourneyTableViewModel>();
    return StreamBuilder(
      stream: CombineLatestStream.list([navigationVM.model, journeyVM.settings]),
      initialData: [navigationVM.modelValue, journeyVM.settingsValue],
      builder: (context, snapshot) {
        final snap = snapshot.data;
        if (snap == null || snap[0] == null || snap[1] == null) return SizedBox.shrink();

        final navigationModel = snap[0] as JourneyNavigationModel;
        final settings = snap[1] as JourneySettings;

        if (!navigationModel.showNavigationButtons) return SizedBox.shrink();

        final resolvedShowNavButtons = navigationModel.showNavigationButtons && !settings.isAutoAdvancementEnabled;

        return AnimatedOpacity(
          opacity: resolvedShowNavButtons ? 1.0 : 0.0,
          duration: _animationDuration,
          child: IgnorePointer(
            ignoring: !resolvedShowNavButtons,
            child: NavigationButtons(
              currentPage: navigationModel.currentIndex,
              numberPages: navigationModel.navigationStackLength,
              onPreviousPressed: () => navigationVM.previous(),
              onNextPressed: () => navigationVM.next(),
            ),
          ),
        );
      },
    );
  }
}

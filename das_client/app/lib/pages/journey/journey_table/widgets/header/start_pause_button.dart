import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_table/advancement/journey_advancement_model.dart';
import 'package:app/pages/journey/journey_table/advancement/journey_table_advancement_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/header/header_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class StartPauseButton extends StatelessWidget {
  static const startButtonKey = Key('startAutomaticAdvancementButton');
  static const pauseButtonKey = Key('pauseAutomaticAdvancementButton');
  static const manualButtonKey = Key('manualAdvancementButton');

  const StartPauseButton({super.key});

  @override
  Widget build(BuildContext context) {
    final journeyTableAdvancementVM = context.read<JourneyTableAdvancementViewModel>();
    return StreamBuilder(
      stream: journeyTableAdvancementVM.model,
      initialData: journeyTableAdvancementVM.modelValue,
      builder: (context, asyncSnapshot) {
        final model = asyncSnapshot.requireData;

        return switch (model) {
          Paused(next: final next) => _button(
            next is Automatic ? startButtonKey : manualButtonKey,
            context.l10n.p_journey_header_button_start,
            next is Automatic ? SBBIcons.play_small : SBBIcons.hand_cursor_small,
            context,
          ),
          Automatic() => _button(
            pauseButtonKey,
            context.l10n.p_journey_header_button_pause,
            SBBIcons.pause_small,
            context,
          ),
          Manual() => _button(
            pauseButtonKey,
            context.l10n.p_journey_header_button_pause,
            SBBIcons.hand_cursor_small,
            context,
          ),
        };
      },
    );
  }

  Widget _button(Key key, String label, IconData icon, BuildContext context) {
    return HeaderIconButton(
      key: key,
      label: label,
      icon: icon,
      onPressed: () {
        context.read<JourneyTableAdvancementViewModel>().toggleAdvancementMode();
      },
    );
  }

  //   final automaticAdvancementActive = asyncSnapshot.requireData.isAutoAdvancementEnabled;
  //   return HeaderIconButton(
  //     key: automaticAdvancementActive ? pauseButtonKey : startButtonKey,
  //     label: automaticAdvancementActive
  //         ? context.l10n.p_journey_header_button_pause
  //         : context.l10n.p_journey_header_button_start,
  //     icon: automaticAdvancementActive ? SBBIcons.pause_small : SBBIcons.play_small,
  //     onPressed: () {
  //       final newValue = !automaticAdvancementActive;
  //       context.read<JourneyTableViewModel>().setAutomaticAdvancement(newValue);
  //     },
  //   );
  // },
  // );
  // }
}

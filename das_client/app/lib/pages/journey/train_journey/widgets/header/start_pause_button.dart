import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/header/animated_header_icon_button.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class StartPauseButton extends StatelessWidget {
  static const startButtonKey = Key('startAutomaticAdvancementButton');
  static const pauseButtonKey = Key('pauseAutomaticAdvancementButton');

  const StartPauseButton({super.key, this.automaticAdvancementActive = false});

  final bool automaticAdvancementActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedHeaderIconButton(
      key: automaticAdvancementActive ? pauseButtonKey : startButtonKey,
      label: automaticAdvancementActive
          ? context.l10n.p_train_journey_header_button_pause
          : context.l10n.p_train_journey_header_button_start,
      icon: automaticAdvancementActive ? SBBIcons.pause_small : SBBIcons.play_small,
      onPressed: () {
        final newValue = !automaticAdvancementActive;
        context.read<TrainJourneyViewModel>().setAutomaticAdvancement(newValue);
      },
    );
  }
}

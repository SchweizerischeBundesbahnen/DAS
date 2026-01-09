import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_table/model/journey_advancement_model.dart';
import 'package:app/pages/journey/journey_table/view_model/journey_table_advancement_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/header/header_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneyAdvancementButton extends StatelessWidget {
  static const startKey = Key('startAutomaticAdvancementButton');
  static const pauseKey = Key('pauseAutomaticAdvancementButton');
  static const manualKey = Key('manualAdvancementButton');

  const JourneyAdvancementButton({super.key});

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
            next is Automatic ? startKey : manualKey,
            context.l10n.p_journey_header_button_start,
            next is Automatic ? SBBIcons.play_small : SBBIcons.hand_cursor_small,
            context,
            invertColors: next is Automatic ? false : true,
          ),
          Automatic() => _button(
            pauseKey,
            context.l10n.p_journey_header_button_pause,
            SBBIcons.pause_small,
            context,
          ),
          Manual() => _button(
            pauseKey,
            context.l10n.p_journey_header_button_pause,
            SBBIcons.hand_cursor_small,
            context,
            invertColors: true,
          ),
        };
      },
    );
  }

  Widget _button(Key key, String label, IconData icon, BuildContext context, {bool invertColors = false}) {
    return HeaderIconButton(
      key: key,
      label: label,
      icon: icon,
      invertColors: invertColors,
      onPressed: () {
        context.read<JourneyTableAdvancementViewModel>().toggleAdvancementMode();
      },
    );
  }
}

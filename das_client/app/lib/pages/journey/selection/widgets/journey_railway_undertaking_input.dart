import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

const _inputPadding = EdgeInsets.fromLTRB(sbbDefaultSpacing, 0, 0, sbbDefaultSpacing);

class JourneyRailwayUndertakingInput extends StatelessWidget {
  const JourneyRailwayUndertakingInput({super.key, this.isModalVersion = false});

  final bool isModalVersion;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final model = snapshot.requireData;

        final currentRu = model.railwayUndertaking;

        return switch (model) {
          final Selecting _ || final Error _ => _buildRailwayUndertakingInput(
            context,
            currentRu,
            onChanged: (value) => viewModel.updateRailwayUndertaking(value),
          ),
          _ => _buildRailwayUndertakingInput(context, currentRu),
        };
      },
    );
  }

  _buildRailwayUndertakingInput(BuildContext context, value, {Function(RailwayUndertaking)? onChanged}) {
    return Padding(
      padding: isModalVersion ? EdgeInsets.zero : _inputPadding,
      child: SBBSelect<RailwayUndertaking>(
        label: isModalVersion ? null : context.l10n.p_train_selection_ru_description,
        hint: isModalVersion ? context.l10n.p_train_selection_ru_description : null,
        value: value,
        items: RailwayUndertaking.values
            .map((ru) => SelectMenuItem<RailwayUndertaking>(value: ru, label: ru.displayText(context)))
            .toList(),
        onChanged: onChanged != null ? (value) => value != null ? onChanged(value) : null : null,
        isLastElement: true,
      ),
    );
  }
}

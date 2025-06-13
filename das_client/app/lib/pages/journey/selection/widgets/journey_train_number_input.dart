import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneyTrainNumberInput extends StatefulWidget {
  const JourneyTrainNumberInput({super.key});

  @override
  State<JourneyTrainNumberInput> createState() => _JourneyTrainNumberInputState();
}

class _JourneyTrainNumberInputState extends State<JourneyTrainNumberInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final model = snapshot.requireData;
        _controller.text = model.operationalTrainNumber;

        return switch (model) {
          final Selecting _ || final Error _ => _buildTrainNumberInput(
            context,
            onChanged: (value) => viewModel.updateTrainNumber(value),
            onSubmitted: (_) => viewModel.loadTrainJourney(),
          ),
          _ => _buildTrainNumberInput(context),
        };
      },
    );
  }

  Widget _buildTrainNumberInput(BuildContext context, {Function(String)? onChanged, Function(String)? onSubmitted}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing, sbbDefaultSpacing, 0, sbbDefaultSpacing / 2),
      child: SBBTextField(
        enabled: onChanged != null,
        onChanged: onChanged,
        controller: _controller,
        labelText: context.l10n.p_train_selection_trainnumber_description,
        keyboardType: TextInputType.text,
        onSubmitted: onSubmitted,
      ),
    );
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }
}

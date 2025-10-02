import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/journey_railway_undertaking_filter_controller.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

const _inputPadding = EdgeInsets.fromLTRB(sbbDefaultSpacing, 0, 0, sbbDefaultSpacing / 2);

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
          final Selecting _ || final Error _ => _RailwayUndertakingTextField(
            selectedRailwayUndertaking: currentRu,
            isModalVersion: isModalVersion,
          ),
          _ => _RailwayUndertakingTextField(
            selectedRailwayUndertaking: currentRu,
            isModalVersion: isModalVersion,
          ),
        };
      },
    );
  }
}

class _RailwayUndertakingTextField extends StatefulWidget {
  const _RailwayUndertakingTextField({
    required this.selectedRailwayUndertaking,
    this.isModalVersion = false,
  });

  final RailwayUndertaking selectedRailwayUndertaking;
  final bool isModalVersion;

  @override
  State<_RailwayUndertakingTextField> createState() => _RailwayUndertakingTextFieldState();
}

class _RailwayUndertakingTextFieldState extends State<_RailwayUndertakingTextField> {
  late JourneyRailwayUndertakingFilterController controller;
  late FocusNode focusNode;

  @override
  void initState() {
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _RailwayUndertakingTextField oldWidget) {
    if (widget.selectedRailwayUndertaking != oldWidget.selectedRailwayUndertaking) {
      controller.selectedRailwayUndertaking = widget.selectedRailwayUndertaking;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    final localizations = AppLocalizations.of(context)!;
    final vm = context.read<JourneySelectionViewModel>();
    final onAvailableRailwayUndertakingsChanged = vm.updateAvailableRailwayUndertakings;
    final updateIsSelectingRailwayUndertaking = vm.updateIsSelectingRailwayUndertaking;

    controller = JourneyRailwayUndertakingFilterController(
      localizations: localizations,
      focusNode: focusNode,
      updateAvailableRailwayUndertakings: onAvailableRailwayUndertakingsChanged,
      updateIsSelectingRailwayUndertaking: updateIsSelectingRailwayUndertaking,
      initialRailwayUndertaking: widget.selectedRailwayUndertaking,
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.isModalVersion ? EdgeInsets.zero : _inputPadding,
      child: SBBTextField(
        focusNode: focusNode,
        controller: controller.textEditingController,
        labelText: widget.isModalVersion ? null : context.l10n.p_train_selection_ru_description,
        hintText: widget.isModalVersion ? context.l10n.p_train_selection_ru_description : null,
        keyboardType: TextInputType.text,
      ),
    );
  }
}

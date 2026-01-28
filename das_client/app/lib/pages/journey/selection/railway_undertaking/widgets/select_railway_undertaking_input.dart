import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/selection/railway_undertaking/widgets/select_railway_undertaking_modal.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/device_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

const _inputPadding = EdgeInsets.fromLTRB(SBBSpacing.medium, 0, 0, SBBSpacing.xSmall);

class SelectRailwayUndertakingInput extends StatelessWidget {
  const SelectRailwayUndertakingInput({super.key, this.isModalVersion = false});

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
  // updates the disabled text field which is tapped to show modal
  TextEditingController? baseTextEditingController;

  @override
  void didUpdateWidget(covariant _RailwayUndertakingTextField oldWidget) {
    if (widget.selectedRailwayUndertaking != oldWidget.selectedRailwayUndertaking) {
      baseTextEditingController?.text = widget.selectedRailwayUndertaking.displayText(context);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    baseTextEditingController ??= TextEditingController(text: widget.selectedRailwayUndertaking.displayText(context));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    baseTextEditingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.isModalVersion ? .zero : _inputPadding,
      child: GestureDetector(
        child: SBBTextField(
          enabled: false,
          controller: baseTextEditingController,
          labelText: widget.isModalVersion ? null : context.l10n.p_train_selection_ru_description,
          hintText: widget.isModalVersion ? context.l10n.p_train_selection_ru_description : null,
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            clipBehavior: .hardEdge,
            backgroundColor: _modalBackgroundColor(context),
            shape: SelectRailwayUndertakingModal.shapeBorder,
            constraints: _modalConstraints,
            builder: (_) => Provider.value(
              value: context.read<JourneySelectionViewModel>(),
              child: SelectRailwayUndertakingModal(
                selectedRailwayUndertaking: widget.selectedRailwayUndertaking,
              ),
            ),
          );
        },
      ),
    );
  }

  Color _modalBackgroundColor(BuildContext context) => ThemeUtil.getColor(
    context,
    SBBColors.cloud,
    SBBColors.charcoal,
  );

  BoxConstraints get _modalConstraints => BoxConstraints(
    maxWidth: DeviceScreen.width - SBBSpacing.medium,
    maxHeight: _maxModalHeight,
  );

  double get _maxModalHeight {
    final topModalMargin = widget.isModalVersion
        ? DeviceScreen.systemStatusBarHeight
        : kToolbarHeight + DeviceScreen.systemStatusBarHeight;
    return DeviceScreen.size.height - topModalMargin;
  }
}

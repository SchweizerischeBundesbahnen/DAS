import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/railway_undertaking/widgets/select_railway_undertaking_modal.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/device_screen.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

const _inputPadding = EdgeInsets.fromLTRB(SBBSpacing.medium, 0, 0, SBBSpacing.xSmall);

class SelectRailwayUndertakingInput extends StatelessWidget {
  const SelectRailwayUndertakingInput({
    required this.selectedRailwayUndertakings,
    required this.updateRailwayUndertaking,
    super.key,
    this.isModalVersion = false,
    this.allowMultiSelect = false,
  });

  final List<RailwayUndertaking> selectedRailwayUndertakings;
  final void Function(List<RailwayUndertaking>) updateRailwayUndertaking;
  final bool isModalVersion;
  final bool allowMultiSelect;

  @override
  Widget build(BuildContext context) {
    return _RailwayUndertakingTextField(
      selectedRailwayUndertaking: selectedRailwayUndertakings,
      updateRailwayUndertaking: updateRailwayUndertaking,
      isModalVersion: isModalVersion,
      allowMultiSelect: allowMultiSelect,
    );
  }
}

class _RailwayUndertakingTextField extends StatefulWidget {
  const _RailwayUndertakingTextField({
    required this.selectedRailwayUndertaking,
    required this.updateRailwayUndertaking,
    this.isModalVersion = false,
    this.allowMultiSelect = false,
  });

  final List<RailwayUndertaking> selectedRailwayUndertaking;
  final void Function(List<RailwayUndertaking>) updateRailwayUndertaking;
  final bool isModalVersion;
  final bool allowMultiSelect;

  @override
  State<_RailwayUndertakingTextField> createState() => _RailwayUndertakingTextFieldState();
}

class _RailwayUndertakingTextFieldState extends State<_RailwayUndertakingTextField> {
  // updates the disabled text field which is tapped to show modal
  TextEditingController? baseTextEditingController;

  @override
  void didUpdateWidget(covariant _RailwayUndertakingTextField oldWidget) {
    if (widget.selectedRailwayUndertaking != oldWidget.selectedRailwayUndertaking) {
      baseTextEditingController?.text = widget.selectedRailwayUndertaking
          .map((it) => it.displayText(context))
          .join(', ');
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    baseTextEditingController ??= TextEditingController(
      text: widget.selectedRailwayUndertaking.map((it) => it.displayText(context)).join(', '),
    );
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
            builder: (_) => SelectRailwayUndertakingModal(
              selectedRailwayUndertaking: widget.selectedRailwayUndertaking,
              allowMultiSelect: widget.allowMultiSelect,
              updateRailwayUndertaking: widget.updateRailwayUndertaking,
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

import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/device_screen.dart';
import 'package:app/widgets/railway_undertaking/widgets/select_railway_undertaking_modal.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

const _inputPadding = EdgeInsets.fromLTRB(SBBSpacing.medium, 0, 0, SBBSpacing.xSmall);

class SelectRailwayUndertakingInput extends StatefulWidget {
  const SelectRailwayUndertakingInput({
    required this.selectedRailwayUndertakings,
    required this.updateRailwayUndertaking,
    super.key,
    this.isModalVersion = false,
    this.allowMultiSelect = false,
    this.isLastElement = false,
  });

  final List<RailwayUndertaking> selectedRailwayUndertakings;
  final void Function(List<RailwayUndertaking>) updateRailwayUndertaking;
  final bool isModalVersion;
  final bool allowMultiSelect;
  final bool isLastElement;

  @override
  State<SelectRailwayUndertakingInput> createState() => _RailwayUndertakingTextFieldState();
}

class _RailwayUndertakingTextFieldState extends State<SelectRailwayUndertakingInput> {
  // updates the disabled text field which is tapped to show modal
  TextEditingController? baseTextEditingController;

  @override
  void didUpdateWidget(covariant SelectRailwayUndertakingInput oldWidget) {
    if (widget.selectedRailwayUndertakings != oldWidget.selectedRailwayUndertakings) {
      baseTextEditingController?.text = widget.selectedRailwayUndertakings
          .map((it) => it.displayText(context))
          .join(', ');
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    baseTextEditingController ??= TextEditingController(
      text: widget.selectedRailwayUndertakings.map((it) => it.displayText(context)).join(', '),
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
          isLastElement: widget.isLastElement,
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
              selectedRailwayUndertaking: widget.selectedRailwayUndertakings,
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

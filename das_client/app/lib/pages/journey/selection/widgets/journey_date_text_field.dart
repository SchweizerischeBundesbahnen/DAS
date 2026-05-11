import 'package:app/i18n/i18n.dart';
import 'package:app/util/format.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

const _inputPadding = EdgeInsets.fromLTRB(SBBSpacing.medium, SBBSpacing.medium, 0, SBBSpacing.xSmall);

class JourneyDateTextField extends StatelessWidget {
  const JourneyDateTextField({required this.onTap, required this.isModalVersion, required this.date, super.key});

  final VoidCallback onTap;
  final bool isModalVersion;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).sbbBaseStyle.colorScheme;
    return Padding(
      padding: isModalVersion ? .zero : _inputPadding,
      child: SBBDecoratedText(
        onTap: onTap,
        value: Format.date(date),
        decoration: SBBInputDecoration(
          labelText: isModalVersion ? null : context.l10n.p_train_selection_date_description,
          placeholderText: isModalVersion ? context.l10n.p_train_selection_date_description : null,
          // TODO: maybe change in DSM so that border is still there even if not boxed or listed.
          borderColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
            WidgetState.error: colorScheme.error,
            WidgetState.focused: colorScheme.strokePrimary,
            WidgetState.any: colorScheme.strokeSeparator,
          }),
        ),
      ),
    );
  }
}

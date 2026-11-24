import 'package:app/i18n/i18n.dart';
import 'package:app/util/format.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneyDateTextField extends StatelessWidget {
  const JourneyDateTextField({required this.onTap, required this.isModalVersion, required this.date, super.key});

  final VoidCallback onTap;
  final bool isModalVersion;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isModalVersion ? .zero : EdgeInsets.fromLTRB(SBBSpacing.medium, SBBSpacing.medium, 0, SBBSpacing.xSmall),
      child: SBBDecoratedText(
        onTap: onTap,
        value: Format.date(date),
        decoration: SBBDecoration(
          style: SBBDecorationStyle(borderType: .standalone),
          labelText: isModalVersion ? null : context.l10n.p_train_selection_date_description,
          placeholderText: isModalVersion ? context.l10n.p_train_selection_date_description : null,
        ),
      ),
    );
  }
}

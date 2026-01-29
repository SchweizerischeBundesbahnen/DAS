import 'package:app/i18n/i18n.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

Future<void> showDepartureProcessModalSheet(BuildContext context) => showSBBModalSheet(
  context: context,
  title: context.l10n.w_departure_process_modal_sheet_title,
  constraints: BoxConstraints(),
  child: DepartureProcessModalSheet(),
);

class DepartureProcessModalSheet extends StatelessWidget {
  const DepartureProcessModalSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const .symmetric(horizontal: SBBSpacing.medium),
      child: Text(
        context.l10n.w_departure_process_modal_sheet_content,
        style: DASTextStyles.mediumRoman,
      ),
    );
  }
}

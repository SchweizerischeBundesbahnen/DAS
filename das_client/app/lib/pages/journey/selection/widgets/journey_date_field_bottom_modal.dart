import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_picker.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_text_field.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// In the JourneyPage, show a bottom modal sheet.
class JourneyDateFieldBottomModal extends StatelessWidget {
  const JourneyDateFieldBottomModal({
    required this.onSelect,
    required this.date,
    required this.availableStartDates,
    super.key,
  });

  final Function(DateTime)? onSelect;
  final DateTime date;
  final List<DateTime> availableStartDates;

  @override
  Widget build(BuildContext context) {
    return JourneyDateTextField(
      onTap: _showBottomSheet(context, date, availableStartDates),
      isModalVersion: true,
      date: date,
    );
  }

  VoidCallback _showBottomSheet(BuildContext context, DateTime selectedDate, List<DateTime> availableStartDates) =>
      () => showSBBModalSheet(
        context: context,
        title: context.l10n.p_train_selection_choose_date,
        constraints: BoxConstraints(maxWidth: 350),
        child: Padding(
          padding: const .symmetric(horizontal: SBBSpacing.medium),
          child: JourneyDatePicker(
            onChanged: (d) {
              onSelect?.call(d);
              context.router.pop();
            },
            selectedDate: selectedDate,
            availableStartDates: availableStartDates,
          ),
        ),
      );
}

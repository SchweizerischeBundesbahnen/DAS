import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/util/format.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneyDatePicker extends StatelessWidget {
  const JourneyDatePicker({required this.selectedDate, required this.availableStartDates, super.key});

  final DateTime selectedDate;
  final List<DateTime> availableStartDates;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(sbbDefaultSpacing),
      child: SBBGroup(
        child: SBBPicker.list(
          initialSelectedIndex: availableStartDates.indexOf(selectedDate),
          items: _listPickerItems(context),
          onSelectedItemChanged: (idx) {
            final updatedDate = availableStartDates.elementAt(idx);
            context.read<JourneySelectionViewModel>().updateDate(updatedDate);
          },
          looping: false,
        ),
      ),
    );
  }

  List<String> _listPickerItems(BuildContext context) =>
      availableStartDates.map((date) => _formattedDate(date, context)).toList();

  String _formattedDate(DateTime date, BuildContext context) {
    if (DateUtils.isSameDay(date, clock.now())) return context.l10n.c_today;

    final locale = Localizations.localeOf(context);
    return Format.dateWithTextMonth(date, locale);
  }
}

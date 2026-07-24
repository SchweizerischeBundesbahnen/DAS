import 'dart:math';

import 'package:app/i18n/i18n.dart';
import 'package:app/util/format.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneyDatePicker extends StatelessWidget {
  static Key get datePickerKey => Key('JourneyDatePicker');

  const JourneyDatePicker({
    required this.onChanged,
    required this.selectedDate,
    required this.availableStartDates,
    super.key,
  });

  final DateTime selectedDate;
  final List<DateTime> availableStartDates;
  final Function(DateTime) onChanged;

  @override
  Widget build(BuildContext context) => SBBContentBox(
    key: datePickerKey,
    margin: .symmetric(vertical: SBBSpacing.xSmall),
    padding: .symmetric(vertical: SBBSpacing.xSmall),
    child: SBBPicker.list(
      initialSelectedIndex: availableStartDates.indexOf(selectedDate),
      onSelectedItemChanged: (idx) => onChanged.call(availableStartDates[idx]),
      items: availableStartDates.map((d) => _formattedDate(d, context)).toList(growable: false),
      looping: false,
      visibleItemCount: min(availableStartDates.length, 3),
    ),
  );

  String _formattedDate(DateTime date, BuildContext context) {
    if (DateUtils.isSameDay(date, clock.now())) return context.l10n.c_today;

    final locale = Localizations.localeOf(context);
    return Format.dateWithTextMonth(date, locale);
  }
}

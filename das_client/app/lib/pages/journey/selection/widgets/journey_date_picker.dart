import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/util/format.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneyDatePicker extends StatefulWidget {
  const JourneyDatePicker({required this.selectedDate, super.key});

  final DateTime selectedDate;

  @override
  State<JourneyDatePicker> createState() => _JourneyDatePickerState();
}

class _JourneyDatePickerState extends State<JourneyDatePicker> {
  late SBBPickerScrollController controller;

  @override
  void initState() {
    controller = SBBPickerScrollController(initialItem: _indexFromDate(widget.selectedDate));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(sbbDefaultSpacing),
      child: SBBGroup(
        child: SBBPicker.list(
          controller: controller,
          onSelectedItemChanged: (idx) => context.read<JourneySelectionViewModel>().updateDate(_dateFromIndex(idx)),
          items: List.generate(_isNextDayInFourHours() ? 3 : 2, (idx) => _formattedDateFromIndex(idx, context)),
          looping: false,
        ),
      ),
    );
  }

  int _indexFromDate(DateTime selectedDate) {
    final today = clock.now().toLocal();
    final selectedLocal = selectedDate.toLocal();

    final deltaDays = DateTime.utc(
      selectedLocal.year,
      selectedLocal.month,
      selectedLocal.day,
    ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;

    return switch (deltaDays) {
      -1 => 0, // yesterday
      0 => 1, // today
      1 => 2, // tomorrow
      _ => -1,
    };
  }

  DateTime _dateFromIndex(int idx) {
    if (idx < 0 || idx > 2) throw RangeError.range(idx, 0, 2, 'idx', 'Index must be 0, 1, or 2');

    final baseLocal = clock.now().toLocal();
    final dayOffset = idx - 1;

    return DateTime.utc(
      baseLocal.year,
      baseLocal.month,
      baseLocal.day,
    ).add(Duration(days: dayOffset)).toLocal();
  }

  String _formattedDateFromIndex(int idx, BuildContext context) =>
      idx == 1 ? context.l10n.c_today : Format.date(_dateFromIndex(idx));

  bool _isNextDayInFourHours() {
    final now = clock.now().toLocal();
    final inFourHours = now.add(Duration(hours: 4));
    return now.day != inFourHours.day;
  }
}

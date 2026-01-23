import 'package:app/i18n/i18n.dart';
import 'package:app/theme/theme_util.dart';
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
    padding: .symmetric(vertical: SBBSpacing.xSmall, horizontal: SBBSpacing.medium),
    child: Column(
      spacing: SBBSpacing.xSmall,
      mainAxisSize: .min,
      children: availableStartDates.map((d) => _dateItem(context, d)).toList(),
    ),
  );

  Widget _dateItem(BuildContext context, DateTime d) {
    final isSelected = d == selectedDate;
    final unselectedTextStyle = SBBTextStyles.extraLargeLight.romanStyle.copyWith(
      color: ThemeUtil.getColor(context, SBBColors.storm, SBBColors.graphite),
    );
    final selectedTextStyle = SBBTextStyles.extraLargeLight.romanStyle.copyWith(
      color: ThemeUtil.getColor(context, SBBColors.black, SBBColors.white),
    );
    return GestureDetector(
      onTap: () => onChanged.call(d),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        constraints: BoxConstraints(minWidth: double.infinity),
        padding: .symmetric(vertical: 2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(SBBSpacing.xSmall)),
          color: isSelected ? ThemeUtil.getColor(context, SBBColors.cloud, SBBColors.iron) : SBBColors.transparent,
        ),
        child: Center(
          child: Text(
            _formattedDate(d, context),
            style: isSelected ? selectedTextStyle : unselectedTextStyle,
          ),
        ),
      ),
    );
  }

  String _formattedDate(DateTime date, BuildContext context) {
    if (DateUtils.isSameDay(date, clock.now())) return context.l10n.c_today;

    final locale = Localizations.localeOf(context);
    return Format.dateWithTextMonth(date, locale);
  }
}

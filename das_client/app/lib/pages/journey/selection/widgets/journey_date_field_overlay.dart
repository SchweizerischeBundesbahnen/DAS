import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_picker.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_text_field.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// On the JourneySelection page, show a full page overlay for quick date selection.
class JourneyDateFieldOverlay extends StatelessWidget {
  static const double _maxWidth = 360;

  const JourneyDateFieldOverlay({
    required this.date,
    required this.availableStartDates,
    required this.onSelect,
    super.key,
  });

  final DateTime date;
  final List<DateTime> availableStartDates;
  final Function(DateTime)? onSelect;

  @override
  Widget build(BuildContext context) => SBBPopover(
    targetBuilder: (_, showPopover) => JourneyDateTextField(
      onTap: showPopover,
      isModalVersion: false,
      date: date,
    ),
    titleText: context.l10n.p_train_selection_choose_date,
    builder: (context, hidePopover) => _picker(context, hidePopover),
    placement: .bottomStart,
    style: SBBPopoverStyle(constraints: BoxConstraints(maxWidth: _maxWidth)),
  );

  Widget _picker(BuildContext context, VoidCallback hideOverlay) => JourneyDatePicker(
    onChanged: (d) {
      onSelect?.call(d);
      hideOverlay();
    },
    selectedDate: date,
    availableStartDates: availableStartDates,
  );
}

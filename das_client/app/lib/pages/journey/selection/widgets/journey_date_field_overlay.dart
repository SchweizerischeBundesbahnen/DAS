import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_picker.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_text_field.dart';
import 'package:app/pages/journey/train_journey/widgets/anchored_full_page_overlay.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// On the JourneySelection page, show a full page overlay for quick date selection.
class JourneyDateFieldOverlay extends StatelessWidget {
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
  Widget build(BuildContext context) => AnchoredFullPageOverlay(
    triggerBuilder: (context, showOverlay) => JourneyDateTextField(
      onTap: showOverlay,
      isModalVersion: false,
      date: date,
    ),
    contentBuilder: (context, hideOverlay) => Column(
      children: [
        _header(context, hideOverlay),
        _picker(context, hideOverlay),
      ],
    ),
    targetAnchor: Alignment.bottomLeft,
    offset: Offset(AnchoredFullPageOverlay.defaultContentWidget * .5 + sbbDefaultSpacing, sbbDefaultSpacing * .5),
  );

  Widget _header(BuildContext context, VoidCallback hideOverlay) {
    return Row(
      children: [
        Expanded(child: Text(context.l10n.p_train_selection_choose_date, style: DASTextStyles.largeLight)),
        SBBIconButtonSmall(icon: SBBIcons.cross_medium, onPressed: hideOverlay),
      ],
    );
  }

  Widget _picker(BuildContext context, VoidCallback hideOverlay) => JourneyDatePicker(
    onChanged: (d) {
      onSelect?.call(d);
      hideOverlay();
    },
    selectedDate: date,
    availableStartDates: availableStartDates,
  );
}

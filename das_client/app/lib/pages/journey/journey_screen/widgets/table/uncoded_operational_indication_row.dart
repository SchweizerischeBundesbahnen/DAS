import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/uncoded_operational_indication_accordion.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class UncodedOperationalIndicationRow extends WidgetRowBuilder<UncodedOperationalIndication> {
  UncodedOperationalIndicationRow({
    required super.rowIndex,
    required super.metadata,
    required super.data,
    required this.collapsedState,
    this.leftPadding = 0,
    super.config,
    super.identifier,
  }) : super(
         stickyLevel: .second,
         height: UncodedOperationalIndicationAccordion.calculateHeight(
           data.combinedText,
           collapsedState: collapsedState,
           leftPadding: leftPadding,
         ),
       );

  final CollapsedState collapsedState;
  final double leftPadding;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      child: UncodedOperationalIndicationAccordion(
        collapsedState: collapsedState,
        leftPadding: leftPadding,
        data: data,
      ),
    );
  }
}

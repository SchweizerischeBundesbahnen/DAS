import 'package:app/pages/journey/journey_table/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/table/uncoded_operational_indication_accordion.dart';
import 'package:app/pages/journey/journey_table/widgets/table/widget_row_builder.dart';
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
    required this.addTopMargin,
    super.config,
    super.identifier,
  }) : super(
         stickyLevel: .second,
         height: UncodedOperationalIndicationAccordion.calculateHeight(
           data.combinedText,
           collapsedState: collapsedState,
           addTopMargin: addTopMargin,
         ),
       );

  final CollapsedState collapsedState;
  final bool addTopMargin;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      child: UncodedOperationalIndicationAccordion(
        collapsedState: collapsedState,
        addTopMargin: addTopMargin,
        data: data,
      ),
    );
  }
}

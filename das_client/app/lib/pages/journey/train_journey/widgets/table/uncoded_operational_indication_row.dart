import 'package:app/pages/journey/train_journey/widgets/table/uncoded_operational_indication_accordion.dart';
import 'package:app/pages/journey/train_journey/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/accordion/accordion.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class UncodedOperationalIndicationRow extends WidgetRowBuilder<UncodedOperationalIndication> {
  UncodedOperationalIndicationRow({
    required super.rowIndex,
    required super.metadata,
    required super.data,
    required this.isExpanded,
    required this.accordionToggleCallback,
    required this.addTopMargin,
    this.expandedContent = false,
    super.config,
    super.identifier,
  }) : super(
         stickyLevel: StickyLevel.second,
         height: UncodedOperationalIndicationAccordion.calculateHeight(
           data.combinedText,
           isExpanded: isExpanded,
           expandedContent: expandedContent,
           addTopMargin: addTopMargin,
         ),
       );

  final bool isExpanded;
  final bool expandedContent;
  final bool addTopMargin;
  final AccordionToggleCallback accordionToggleCallback;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      child: UncodedOperationalIndicationAccordion(
        isExpanded: isExpanded,
        expandedContent: expandedContent,
        addTopMargin: addTopMargin,
        accordionToggleCallback: accordionToggleCallback,
        data: data,
      ),
    );
  }
}

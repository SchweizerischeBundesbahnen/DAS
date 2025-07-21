import 'package:app/pages/journey/train_journey/widgets/table/foot_note_accordion.dart';
import 'package:app/pages/journey/train_journey/widgets/table/foot_note_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/uncoded_operational_indication_accordion.dart';
import 'package:app/pages/journey/train_journey/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/accordion/accordion.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class AccordionConfig {
  AccordionConfig({
    required this.isExpanded,
    required this.toggleCallback,
    this.isContentExpanded = false,
  });

  final bool isExpanded;
  final bool isContentExpanded;
  final AccordionToggleCallback toggleCallback;
}

class CombinedFootNoteOperationalIndicationRow extends WidgetRowBuilder<CombinedFootNoteOperationalIndication> {
  static const Key rowKey = Key('combinedFootNoteOperationalIndicationRow');

  CombinedFootNoteOperationalIndicationRow({
    required super.rowIndex,
    required super.metadata,
    required super.data,
    required this.footNoteConfig,
    required this.operationIndicationConfig,
    super.config,
    super.identifier,
  }) : super(
         stickyLevel: StickyLevel.second,
         height:
             UncodedOperationalIndicationAccordion.calculateHeight(
               data.operationalIndication.combinedText,
               isExpanded: operationIndicationConfig.isExpanded,
               expandedContent: operationIndicationConfig.isContentExpanded,
               addTopMargin: true,
             ) +
             FootNoteAccordion.calculateHeight(
               data: data.footNote,
               isExpanded: footNoteConfig.isExpanded,
               addTopMargin: false,
             ),
       );

  final AccordionConfig footNoteConfig;
  final AccordionConfig operationIndicationConfig;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      key: rowKey,
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      child: Column(
        children: [
          UncodedOperationalIndicationAccordion(
            isExpanded: operationIndicationConfig.isExpanded,
            expandedContent: operationIndicationConfig.isContentExpanded,
            addTopMargin: true,
            accordionToggleCallback: operationIndicationConfig.toggleCallback,
            data: data.operationalIndication,
          ),
          FootNoteAccordion(
            title: data.footNote.title(context, metadata),
            isExpanded: footNoteConfig.isExpanded,
            addTopMargin: false,
            accordionToggleCallback: footNoteConfig.toggleCallback,
            data: data.footNote,
          ),
        ],
      ),
    );
  }
}

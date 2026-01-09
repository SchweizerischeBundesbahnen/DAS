import 'package:app/pages/journey/journey_table/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/table/foot_note_accordion.dart';
import 'package:app/pages/journey/journey_table/widgets/table/foot_note_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/uncoded_operational_indication_accordion.dart';
import 'package:app/pages/journey/journey_table/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class CombinedFootNoteOperationalIndicationRow extends WidgetRowBuilder<CombinedFootNoteOperationalIndication> {
  static const Key rowKey = Key('combinedFootNoteOperationalIndicationRow');

  CombinedFootNoteOperationalIndicationRow({
    required super.rowIndex,
    required super.metadata,
    required super.data,
    required this.footNoteState,
    required this.operationIndicationState,
    super.config,
    super.identifier,
  }) : super(
         stickyLevel: .second,
         height:
             UncodedOperationalIndicationAccordion.calculateHeight(
               data.operationalIndication.combinedText,
               collapsedState: operationIndicationState,
               addTopMargin: true,
             ) +
             FootNoteAccordion.calculateHeight(
               data: data.footNote,
               isExpanded: footNoteState != .collapsed,
               addTopMargin: false,
             ),
       );

  final CollapsedState footNoteState;
  final CollapsedState operationIndicationState;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      key: rowKey,
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      child: Column(
        children: [
          UncodedOperationalIndicationAccordion(
            collapsedState: operationIndicationState,
            addTopMargin: true,
            data: data.operationalIndication,
          ),
          FootNoteAccordion(
            title: data.footNote.title(context, metadata),
            isExpanded: footNoteState != .collapsed,
            addTopMargin: false,
            data: data.footNote,
          ),
        ],
      ),
    );
  }
}

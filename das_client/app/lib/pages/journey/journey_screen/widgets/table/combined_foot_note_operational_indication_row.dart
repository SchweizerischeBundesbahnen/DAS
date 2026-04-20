import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/foot_note_accordion.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/foot_note_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/uncoded_operational_indication_accordion.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/widget_row_builder.dart';
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
    this.leftPadding = 0,
  }) : super(
         stickyLevel: .second,
         height:
             UncodedOperationalIndicationAccordion.calculateHeight(
               data.operationalIndication.combinedText,
               collapsedState: operationIndicationState,
               leftPadding: leftPadding,
             ) +
             FootNoteAccordion.calculateHeight(
               data: data.footNote,
               isExpanded: footNoteState != .collapsed,
               addTopMargin: false,
               leftPadding: leftPadding,
             ),
       );

  final CollapsedState footNoteState;
  final CollapsedState operationIndicationState;

  /// used to align content with information cell
  final double leftPadding;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      key: rowKey,
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      child: Column(
        children: [
          UncodedOperationalIndicationAccordion(
            collapsedState: operationIndicationState,
            data: data.operationalIndication,
            leftPadding: leftPadding,
          ),
          FootNoteAccordion(
            title: data.footNote.title(context, metadata),
            isExpanded: footNoteState != .collapsed,
            addTopMargin: false,
            data: data.footNote,
            leftPadding: leftPadding,
          ),
        ],
      ),
    );
  }
}

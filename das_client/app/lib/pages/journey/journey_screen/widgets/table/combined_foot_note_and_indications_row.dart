import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/combined_foot_note_and_indications.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/foot_note_accordion.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/foot_note_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/indication_accordion.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class CombinedFootNoteAndIndicationsRow extends WidgetRowBuilder<CombinedFootNoteAndIndications> {
  static const Key rowKey = Key('combinedFootNoteAndIndicationsRow');

  CombinedFootNoteAndIndicationsRow({
    required super.rowIndex,
    required super.metadata,
    required super.data,
    required this.footNoteState,
    required this.indicationStates,
    super.config,
    super.identifier,
    this.leftPadding = 0,
  }) : super(
         stickyLevel: .second,
         height:
             data.indications
                 .map(
                   (indication) => IndicationAccordion.calculateHeight(
                     indication,
                     collapsedState: indicationStates.stateOf(indication),
                     leftPadding: leftPadding,
                     isLastElement: data.indications.last == indication && data.footNote == null,
                   ),
                 )
                 .sum +
             (data.footNote != null
                 ? FootNoteAccordion.calculateHeight(
                     data: data.footNote!,
                     isExpanded: footNoteState != .collapsed,
                     addTopMargin: false,
                     leftPadding: leftPadding,
                   )
                 : 0),
       );

  final CollapsedState footNoteState;
  final Map<int, CollapsedState> indicationStates;

  /// used to align content with information cell
  final double leftPadding;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      key: rowKey,
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      child: Column(
        children: [
          ...data.indications.map(
            (indication) => IndicationAccordion(
              collapsedState: indicationStates.stateOf(indication),
              data: indication,
              leftPadding: leftPadding,
              isLastElement: data.indications.last == indication && data.footNote == null,
            ),
          ),
          if (data.footNote != null)
            FootNoteAccordion(
              title: data.footNote!.title(context, metadata),
              isExpanded: footNoteState != .collapsed,
              addTopMargin: false,
              data: data.footNote!,
              leftPadding: leftPadding,
            ),
        ],
      ),
    );
  }
}

import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/basic_text_accordion.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:core_data/component.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BasicTextAccordionRow extends WidgetRowBuilder<JourneyAnnotation> {
  BasicTextAccordionRow({
    required super.rowIndex,
    required super.metadata,
    required super.data,
    required this.collapsedState,
    this.leftPadding = 0,
    super.key,
    super.config,
  }) : super(
         stickyLevel: .second,
         height: BasicTextAccordion.calculateHeight(
           data,
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
      child: BasicTextAccordion(
        collapsedState: collapsedState,
        leftPadding: leftPadding,
        data: data,
      ),
    );
  }
}

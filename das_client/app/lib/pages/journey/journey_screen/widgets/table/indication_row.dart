import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/indication_accordion.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:core_data/component.dart';
import 'package:flutter/material.dart';
import 'package:ru_indications/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class IndicationRow extends WidgetRowBuilder<JourneyAnnotation> {
  IndicationRow({
    required super.rowIndex,
    required super.metadata,
    required super.data,
    required this.collapsedState,
    this.leftPadding = 0,
    super.config,
    super.identifier,
  }) : assert(data is RuIndication || data is OperationalIndication, 'Unsupported data type for indication'),
       super(
         stickyLevel: .second,
         height: IndicationAccordion.calculateHeight(
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
      child: IndicationAccordion(
        collapsedState: collapsedState,
        leftPadding: leftPadding,
        data: data,
      ),
    );
  }
}

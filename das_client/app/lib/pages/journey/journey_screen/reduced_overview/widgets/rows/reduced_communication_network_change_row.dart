import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/row/das_table_row_decoration.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class ReducedCommunicationNetworkChangeRow extends CellRowBuilder<CommunicationNetworkChange> {
  ReducedCommunicationNetworkChangeRow({
    required super.key,
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required BuildContext context,
  }) : super(
         decoration: DASTableRowDecoration(color: ThemeUtil.getDASTableColor(context)),
         journeyPosition: JourneyPositionModel(),
       );

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      alignment: .centerLeft,
      child: Text(
        '${context.l10n.p_journey_table_kilometre_label} ${data.kilometre[0].toStringAsFixed(1)}',
        style: sbbTextStyle.romanStyle.large,
      ),
    );
  }
}

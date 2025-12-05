import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/journey_table/widgets/table/cell_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

class ReducedCommunicationNetworkChangeRow extends CellRowBuilder<CommunicationNetworkChange> {
  final BuildContext context;

  ReducedCommunicationNetworkChangeRow({
    required super.key,
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required this.context,
  }) : super(rowColor: ThemeUtil.getDASTableColor(context), journeyPosition: JourneyPositionModel());

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      alignment: .centerLeft,
      child: Text(
        '${context.l10n.p_journey_table_kilometre_label} ${data.kilometre[0].toStringAsFixed(1)}',
        style: DASTextStyles.largeRoman,
      ),
    );
  }
}

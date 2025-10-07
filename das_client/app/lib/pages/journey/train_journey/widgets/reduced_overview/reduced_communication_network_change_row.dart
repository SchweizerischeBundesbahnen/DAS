import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:sfera/component.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/table/das_table_cell.dart';

class ReducedCommunicationNetworkChannelRow extends CellRowBuilder<CommunicationNetworkChannel> {
  final BuildContext context;

  ReducedCommunicationNetworkChannelRow({
    required super.key,
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required this.context,
  }) : super(rowColor: ThemeUtil.getDASTableColor(context));

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(
            '${context.l10n.p_train_journey_table_kilometre_label} ${data.kilometre[0].toStringAsFixed(1)}',
            style: DASTextStyles.largeRoman,
          ),
        ],
      ),
    );
  }
}

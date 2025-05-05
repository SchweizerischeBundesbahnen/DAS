import 'package:app/app/i18n/i18n.dart';
import 'package:app/app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

class LevelCrossingRow extends CellRowBuilder<LevelCrossing> {
  LevelCrossingRow({
    required super.metadata,
    required super.data,
    super.config,
    super.isGrouped,
  });

  @override
  DASTableCell kilometreCell(BuildContext context) {
    return isGrouped ? DASTableCell.empty() : super.kilometreCell(context);
  }

  @override
  DASTableCell timeCell(BuildContext context) {
    if (!isGrouped) {
      return DASTableCell.empty();
    }

    if (data.kilometre.isEmpty) {
      return DASTableCell.empty(color: specialCellColor);
    } else {
      return DASTableCell(color: specialCellColor, child: Text(data.kilometre[0].toStringAsFixed(3)));
    }
  }

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Text(context.l10n.p_train_journey_table_level_crossing),
      alignment: Alignment.centerLeft,
    );
  }
}

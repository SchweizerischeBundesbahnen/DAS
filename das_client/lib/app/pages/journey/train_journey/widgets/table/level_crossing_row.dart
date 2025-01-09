import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/level_crossing.dart';
import 'package:flutter/material.dart';

class LevelCrossingRow extends BaseRowBuilder<LevelCrossing> {
  LevelCrossingRow({
    required super.metadata,
    required super.data,
    required super.settings,
    super.trackEquipmentRenderData,
  });

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Text(context.l10n.p_train_journey_table_level_crossing),
      alignment: Alignment.centerRight,
    );
  }
}

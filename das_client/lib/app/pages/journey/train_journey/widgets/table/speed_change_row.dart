import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/speed_change.dart';
import 'package:flutter/material.dart';

class SpeedChangeRow extends BaseRowBuilder<SpeedChange> {
  SpeedChangeRow({
    required super.metadata,
    required super.data,
    required super.settings,
  });

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Text(data.text ?? ''),
    );
  }
}

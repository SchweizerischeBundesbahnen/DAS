import 'package:das_client/app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ReducedServicePointRow extends ServicePointRow {
  ReducedServicePointRow({
    required super.metadata,
    required super.data,
    super.config,
  }) : super(rowColor: SBBColors.white);

  @override
  DASTableCell localSpeedCell(BuildContext context) {
    return DASTableCell.empty();
  }
}

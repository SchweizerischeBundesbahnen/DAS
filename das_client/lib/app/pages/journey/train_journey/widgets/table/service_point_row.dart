import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

// TODO: Extract real values from SFERA objects.
class ServicePointRow extends BaseRowBuilder {
  ServicePointRow({
    super.height = 64.0,
    super.defaultAlignment = _defaultAlignment,
    super.kilometre,
    super.isCurrentPosition,
    super.isServicePointStop,
    this.timingPoint,
    this.timingPointConstraints,
    bool nextStop = false,
  }) : super(
    rowColor: nextStop ? SBBColors.royal.withOpacity(0.2) : Colors.transparent,
  );

  final TimingPoint? timingPoint;
  final TimingPointConstraints? timingPointConstraints;

  static const Alignment _defaultAlignment = Alignment.bottomCenter;

  @override
  DASTableCell informationCell() {
    final servicePointName = timingPoint?.names.first.name ?? 'Unknown';
    return DASTableCell(
      alignment: _defaultAlignment,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(servicePointName, style: SBBTextStyles.largeBold.copyWith(fontSize: 24.0)),
          Spacer(),
          Text('B12'),
        ],
      ),
    );
  }
}

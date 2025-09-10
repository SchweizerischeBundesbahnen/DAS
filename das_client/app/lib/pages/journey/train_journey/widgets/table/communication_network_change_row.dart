import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:sfera/component.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/table/das_table_cell.dart';

class CommunicationNetworkChangeRow extends CellRowBuilder<CommunicationNetworkChannel> {
  CommunicationNetworkChangeRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.journeyPosition,
  });

  @override
  DASTableCell kilometreCell(BuildContext context) {
    if (data.kilometre.isEmpty) {
      return DASTableCell(child: Text('no'));
      //return DASTableCell.empty(color: specialCellColor);
    } else {
      return DASTableCell(
        color: specialCellColor,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: OverflowBox(
            maxWidth: double.infinity,
            child: Text(data.kilometre[0].toStringAsFixed(3)),
          ),
        ),
        clipBehaviour: Clip.none,
      );
    }
  }

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Text(data.communicationNetworkType.toString()),
      alignment: Alignment.centerRight,
    );
  }
}

import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

class NetworkCommunicationChannelRow extends CellRowBuilder<CommunicationNetworkChannel> {
  NetworkCommunicationChannelRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    super.config,
  });

  @override
  DASTableCell kilometreCell(BuildContext context) {
    if (!isGrouped) super.kilometreCell(context);

    if (data.kilometre.isEmpty) {
      return DASTableCell.empty(color: specialCellColor);
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
      //todo change content
      child: Text('this is crazy'),
      alignment: Alignment.centerRight,
    );
  }
}

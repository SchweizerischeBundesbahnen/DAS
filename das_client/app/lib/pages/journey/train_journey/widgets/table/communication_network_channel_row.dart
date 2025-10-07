import 'package:app/pages/journey/train_journey/widgets/communication_network_icon.dart';
import 'package:app/pages/journey/train_journey/widgets/header/sim_identifier.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/table/das_table_cell.dart';

class CommunicationNetworkChannelRow extends CellRowBuilder<CommunicationNetworkChannel> {
  final BuildContext context;

  CommunicationNetworkChannelRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required this.context,
    super.config,
  }) : super(rowColor: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black));

  @override
  DASTableCell kilometreCell(BuildContext context) {
    if (data.kilometre.isEmpty) {
      return DASTableCell.empty(color: specialCellColor);
    } else {
      return DASTableCell(
        color: specialCellColor,
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        clipBehaviour: Clip.none,
        child: Text(
          data.kilometre[0].toStringAsFixed(1),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }

  @override
  DASTableCell informationCell(BuildContext context) {
    final networkType = data.communicationNetworkType;
    return DASTableCell(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          if (networkType == CommunicationNetworkType.sim)
            Flexible(
              child: SimIdentifier(textStyle: DASTextStyles.largeRoman),
            )
          else ...[
            Flexible(
              child: Text(
                'GSM',
                style: DASTextStyles.largeRoman,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: sbbDefaultSpacing / 2),
            CommunicationNetworkIcon(networkType: networkType),
          ],
        ],
      ),
    );
  }
}

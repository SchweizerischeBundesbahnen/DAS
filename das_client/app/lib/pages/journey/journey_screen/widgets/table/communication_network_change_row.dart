import 'package:app/pages/journey/journey_screen/header/widgets/sim_identifier.dart';
import 'package:app/pages/journey/journey_screen/widgets/communication_network_icon.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/row/das_table_row_decoration.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class CommunicationNetworkChangeRow extends CellRowBuilder<CommunicationNetworkChange> {
  CommunicationNetworkChangeRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.journeyPosition,
    required BuildContext context,
    super.config,
  }) : super(decoration: DASTableRowDecoration(color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black)));

  @override
  DASTableCell kilometreCell(BuildContext context) {
    if (data.kilometre.isEmpty) {
      return DASTableCell.empty(decoration: DASTableCellDecoration(color: specialCellColor));
    } else {
      return DASTableCell(
        decoration: DASTableCellDecoration(color: specialCellColor),
        padding: const .all(8.0),
        alignment: .centerLeft,
        clipBehavior: .none,
        child: Text(
          data.kilometre[0].toStringAsFixed(1),
          maxLines: 1,
          softWrap: false,
          overflow: .ellipsis,
        ),
      );
    }
  }

  @override
  DASTableCell informationCell(BuildContext context) {
    final networkType = data.communicationNetworkType;
    return DASTableCell(
      alignment: .centerLeft,
      child: Row(
        children: [
          if (networkType == .sim)
            Flexible(
              child: SimIdentifier(textStyle: sbbTextStyle.romanStyle.large),
            )
          else ...[
            Flexible(
              child: Text(
                'GSM',
                style: sbbTextStyle.romanStyle.large,
                maxLines: 1,
                softWrap: false,
                overflow: .ellipsis,
              ),
            ),
            const SizedBox(width: SBBSpacing.xSmall),
            CommunicationNetworkIcon(networkType: networkType),
          ],
        ],
      ),
    );
  }
}

import 'package:app/pages/journey/journey_screen/header/widgets/sim_identifier.dart';
import 'package:app/pages/journey/journey_screen/widgets/communication_network_icon.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class CommunicationNetworkChangeRow extends CellRowBuilder<CommunicationNetworkChange> {
  final BuildContext context;

  CommunicationNetworkChangeRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required this.context,
    required super.journeyPosition,
    super.config,
  }) : super(rowColor: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black));

  @override
  DASTableCell kilometreCell(BuildContext context) {
    if (data.kilometre.isEmpty) {
      return DASTableCell.empty(color: specialCellColor);
    } else {
      return DASTableCell(
        color: specialCellColor,
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
              child: SimIdentifier(textStyle: DASTextStyles.largeRoman),
            )
          else ...[
            Flexible(
              child: Text(
                'GSM',
                style: DASTextStyles.largeRoman,
                maxLines: 1,
                softWrap: false,
                overflow: .ellipsis,
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

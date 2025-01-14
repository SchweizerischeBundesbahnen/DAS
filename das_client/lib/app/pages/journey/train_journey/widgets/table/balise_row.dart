import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/balise.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BaliseRow extends BaseRowBuilder<Balise> {
  static const Key baliseIconKey = Key('balise_icon_key');

  BaliseRow({
    required super.metadata,
    required super.data,
    required super.settings,
    super.trackEquipmentRenderData,
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

    return DASTableCell(color: specialCellColor, child: Text(data.kilometre[0].toStringAsFixed(3)));
  }

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Text(data.amountLevelCrossings > 1
          ? '(${data.amountLevelCrossings} ${context.l10n.p_train_journey_table_level_crossing})'
          : ''),
      alignment: Alignment.centerRight,
    );
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell(
      padding: EdgeInsets.all(sbbDefaultSpacing * 0.25),
      child: SvgPicture.asset(
        AppAssets.iconBalise,
        key: baliseIconKey,
      ),
      alignment: Alignment.centerLeft,
    );
  }
}

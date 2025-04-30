import 'package:app/app/i18n/i18n.dart';
import 'package:app/app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/app/widgets/assets.dart';
import 'package:app/app/widgets/table/das_table_cell.dart';
import 'package:app/model/journey/balise.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BaliseRow extends CellRowBuilder<Balise> {
  static const Key baliseIconKey = Key('baliseIcon');

  BaliseRow({
    required super.metadata,
    required super.data,
    super.config,
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

    if (data.kilometre.isEmpty) {
      return DASTableCell.empty(color: specialCellColor);
    } else {
      return DASTableCell(color: specialCellColor, child: Text(data.kilometre[0].toStringAsFixed(3)));
    }
  }

  @override
  DASTableCell informationCell(BuildContext context) {
    final levelCrossingCount = '(${data.amountLevelCrossings} ${context.l10n.p_train_journey_table_level_crossing})';
    return DASTableCell(
      child: Text(data.amountLevelCrossings > 1 && !isGrouped ? levelCrossingCount : ''),
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
        colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
      ),
      alignment: Alignment.centerLeft,
    );
  }
}

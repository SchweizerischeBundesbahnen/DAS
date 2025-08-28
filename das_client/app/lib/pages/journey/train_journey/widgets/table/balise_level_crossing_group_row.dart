import 'dart:core';

import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class BaliseLevelCrossingGroupRow extends CellRowBuilder<BaliseLevelCrossingGroup> {
  static const Key baliseIconKey = Key('baliseIcon');
  final bool isExpanded;
  final BuildContext context;

  BaliseLevelCrossingGroupRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.journeyPosition,
    required this.isExpanded,
    required this.context,
    super.config,
    super.onTap,
  }) : super(rowColor: isExpanded ? ThemeUtil.getColor(context, SBBColors.cloud, SBBColors.iron) : null);

  @override
  DASTableCell informationCell(BuildContext context) {
    if (_baliseCount == 0) {
      return DASTableCell(
        child: Text('$_levelCrossingCount ${context.l10n.p_train_journey_table_level_crossing}'),
        alignment: Alignment.centerLeft,
      );
    } else if (_baliseCount == 1 && _levelCrossingCount > 1) {
      return DASTableCell(
        child: Text('($_levelCrossingCount ${context.l10n.p_train_journey_table_level_crossing})'),
        alignment: Alignment.centerRight,
      );
    } else {
      return DASTableCell(
        child: Row(
          children: [
            Text(_levelCrossingCount > 0 ? context.l10n.p_train_journey_table_level_crossing : ''),
            Spacer(),
            Text(_baliseCount > 1 ? _baliseCount.toString() : ''),
          ],
        ),
        alignment: Alignment.centerRight,
      );
    }
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    if (_baliseCount > 0) {
      return DASTableCell(
        padding: EdgeInsets.all(sbbDefaultSpacing * 0.25),
        child: SvgPicture.asset(
          AppAssets.iconBalise,
          key: baliseIconKey,
          colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
        ),
        alignment: Alignment.centerLeft,
      );
    } else {
      return DASTableCell.empty();
    }
  }

  int get _baliseCount => data.groupedElements.whereType<Balise>().length;

  int get _levelCrossingCount => data.groupedElements.whereType<LevelCrossing>().length;
}

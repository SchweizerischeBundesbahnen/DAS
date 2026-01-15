import 'dart:core';

import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class BaliseLevelCrossingGroupRow extends CellRowBuilder<BaliseLevelCrossingGroup> {
  static const Key baliseIconKey = Key('baliseIcon');

  BaliseLevelCrossingGroupRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.journeyPosition,
    required this.isExpanded,
    required BuildContext context,
    super.config,
    super.onTap,
  }) : super(rowColor: isExpanded ? ThemeUtil.getColor(context, SBBColors.cloud, SBBColors.iron) : null);

  final bool isExpanded;

  @override
  DASTableCell informationCell(BuildContext context) {
    final firstBalise = data.groupedElements.whereType<Balise>().firstOrNull;
    final baliseGroup = metadata.levelCrossingGroups.whereType<SupervisedLevelCrossingGroup>().firstWhereOrNull(
      (element) => element.balise == firstBalise,
    );
    final shownLevelCrossingsCount = baliseGroup?.shownLevelCrossingsCount() ?? 0;

    if (firstBalise == null) {
      return DASTableCell(
        child: Text('$_levelCrossingCount ${context.l10n.p_journey_table_level_crossing}'),
        alignment: .centerLeft,
      );
    } else if (shownLevelCrossingsCount > 1) {
      return DASTableCell(
        child: Text(
          '($shownLevelCrossingsCount ${context.l10n.p_journey_table_level_crossing})',
        ),
        alignment: .centerRight,
      );
    } else {
      return DASTableCell(
        child: Row(
          children: [
            Text(_levelCrossingCount > 0 ? context.l10n.p_journey_table_level_crossing : ''),
            Spacer(),
            Text(_baliseCount > 1 ? _baliseCount.toString() : ''),
          ],
        ),
        alignment: .centerRight,
      );
    }
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    if (_baliseCount > 0) {
      return DASTableCell(
        padding: .all(sbbDefaultSpacing * 0.25),
        child: SvgPicture.asset(
          AppAssets.iconBalise,
          key: baliseIconKey,
          colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
        ),
        alignment: .centerLeft,
      );
    } else {
      return DASTableCell.empty();
    }
  }

  @override
  bool get isCurrentPosition {
    final isGroupPosition = !isExpanded && data.groupedElements.contains(journeyPosition.currentPosition);
    return super.isCurrentPosition || isGroupPosition;
  }

  int get _baliseCount => data.groupedElements.whereType<Balise>().length;

  int get _levelCrossingCount => data.groupedElements.whereType<LevelCrossing>().length;
}

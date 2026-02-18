import 'dart:core';

import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/row/das_table_row_decoration.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class BaliseLevelCrossingGroupRow extends CellRowBuilder<BaliseLevelCrossingGroup> {
  static const Key iconLevelCrossingKey = Key('baliseLevelCrossingGroupLevelCrossingIcon');
  static const Key iconBaliseKey = Key('baliseLevelCrossingGroupBaliseIcon');

  BaliseLevelCrossingGroupRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.journeyPosition,
    required this.isExpanded,
    required BuildContext context,
    super.config,
    super.onTap,
  }) : super(
         decoration: DASTableRowDecoration(
           color: isExpanded ? ThemeUtil.getColor(context, SBBColors.cloud, SBBColors.iron) : null,
         ),
       );

  final bool isExpanded;

  @override
  DASTableCell informationCell(BuildContext context) {
    final firstBalise = data.groupedElements.whereType<Balise>().firstOrNull;
    return firstBalise == null ? _levelCrossingOnlyCell(context) : _withBaliseCell(context, firstBalise);
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    if (_baliseCount == 0) return DASTableCell.empty();

    return DASTableCell(
      padding: .all(SBBSpacing.xxSmall),
      child: SvgPicture.asset(
        AppAssets.iconBalise,
        key: iconBaliseKey,
        colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
      ),
      alignment: .centerLeft,
    );
  }

  @override
  bool get isCurrentPosition {
    final isGroupPosition = !isExpanded && data.groupedElements.contains(journeyPosition.currentPosition);
    return super.isCurrentPosition || isGroupPosition;
  }

  DASTableCell _withBaliseCell(BuildContext context, Balise firstBalise) {
    final baliseGroup = metadata.levelCrossingGroups.whereType<SupervisedLevelCrossingGroup>().firstWhereOrNull(
      (element) => element.balise == firstBalise,
    );
    final shownLevelCrossingsCount = baliseGroup?.shownLevelCrossingsCount() ?? 0;
    if (shownLevelCrossingsCount > 1) {
      return DASTableCell(
        child: Text(
          '($shownLevelCrossingsCount ${context.l10n.p_journey_table_level_crossing})',
        ),
        alignment: .centerRight,
      );
    }
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

  DASTableCell _levelCrossingOnlyCell(BuildContext context) {
    if (_isInEtcsLevel2Segment) {
      return DASTableCell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: SBBSpacing.xSmall,
          children: [
            Text('$_levelCrossingCount'),
            SvgPicture.asset(
              AppAssets.iconOpenLevelCrossing,
              key: iconLevelCrossingKey,
              colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
            ),
          ],
        ),
        alignment: .centerRight,
      );
    }

    return DASTableCell(
      child: Text('$_levelCrossingCount ${context.l10n.p_journey_table_level_crossing}'),
      alignment: .centerLeft,
    );
  }

  int get _baliseCount => data.groupedElements.whereType<Balise>().length;

  int get _levelCrossingCount => data.groupedElements.whereType<LevelCrossing>().length;

  bool get _isInEtcsLevel2Segment => metadata.nonStandardTrackEquipmentSegments.isInEtcsLevel2Segment(data.order);
}

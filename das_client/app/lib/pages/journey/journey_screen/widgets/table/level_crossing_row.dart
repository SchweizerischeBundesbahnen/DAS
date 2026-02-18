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

class LevelCrossingRow extends CellRowBuilder<LevelCrossing> {
  static const Key iconLevelCrossingKey = Key('levelCrossingIcon');
  static const Key iconBaliseKey = Key('levelCrossingBaliseIcon');

  LevelCrossingRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.journeyPosition,
    super.config,
    super.isGrouped,
  });

  @override
  DASTableCell kilometreCell(BuildContext context) {
    if (!isGrouped) return super.kilometreCell(context);

    if (data.kilometre.isEmpty) return DASTableCell.empty(decoration: DASTableCellDecoration(color: specialCellColor));

    return DASTableCell(
      decoration: DASTableCellDecoration(color: specialCellColor),
      child: Padding(
        padding: .only(left: 8.0),
        child: OverflowBox(
          maxWidth: double.infinity,
          child: Text(data.kilometre[0].toStringAsFixed(3)),
        ),
      ),
      clipBehavior: .none,
      alignment: .centerLeft,
    );
  }

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: _isInEtcsLevel2Segment
          ? _icon(context, AppAssets.iconOpenLevelCrossing, iconLevelCrossingKey)
          : Text(context.l10n.p_journey_table_level_crossing),
      alignment: .centerRight,
    );
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    final group = metadata.levelCrossingGroups.whereType<SupervisedLevelCrossingGroup>().firstWhereOrNull(
      (element) => element.levelCrossings.contains(data),
    );

    if (group != null && group.shouldShowBaliseIconForLevelCrossing(data)) {
      return DASTableCell(
        padding: .all(SBBSpacing.xxSmall),
        child: _icon(context, AppAssets.iconBalise, iconBaliseKey),
        alignment: .centerLeft,
      );
    } else {
      return DASTableCell.empty();
    }
  }

  Widget _icon(BuildContext context, String assetName, Key key) {
    return SvgPicture.asset(
      assetName,
      key: key,
      colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
    );
  }

  bool get _isInEtcsLevel2Segment => metadata.nonStandardTrackEquipmentSegments.isInEtcsLevel2Segment(data.order);
}

import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/balise.dart';
import 'package:das_client/model/journey/balise_level_crossing_group.dart';
import 'package:das_client/model/journey/level_crossing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BaliseLevelCrossingGroupRow extends BaseRowBuilder<BaliseLevelCrossingGroup> {
  static const Key baliseIconKey = Key('balise_icon_key');

  const BaliseLevelCrossingGroupRow({
    required super.metadata,
    required super.data,
    super.config,
    super.onTap,
  });

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

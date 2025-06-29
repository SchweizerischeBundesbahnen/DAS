import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class SpeedChangeRow extends CellRowBuilder<SpeedChange> {
  static const Key kmIndicatorKey = Key('kmIndicator');

  SpeedChangeRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    super.config,
  });

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Text(data.text ?? '', overflow: TextOverflow.ellipsis),
    );
  }

  @override
  DASTableCell brakedWeightSpeedCell(BuildContext context) {
    return speedCell(data.speeds, DASTableCell.empty());
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell(
      padding: EdgeInsets.all(sbbDefaultSpacing * 0.25),
      child: SvgPicture.asset(
        AppAssets.iconKmIndicator,
        key: kmIndicatorKey,
        colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
      ),
      alignment: Alignment.centerLeft,
    );
  }
}

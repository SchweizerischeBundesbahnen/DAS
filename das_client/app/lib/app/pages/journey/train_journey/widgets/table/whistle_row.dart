import 'package:app/app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/app/widgets/assets.dart';
import 'package:app/app/widgets/table/das_table_cell.dart';
import 'package:app/model/journey/whistles.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class WhistleRow extends CellRowBuilder<Whistle> {
  static const Key whistleIconKey = Key('whistleIcon');

  WhistleRow({
    required super.metadata,
    required super.data,
    super.config,
  });

  @override
  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell(
      padding: EdgeInsets.all(sbbDefaultSpacing * 0.25),
      child: SvgPicture.asset(
        AppAssets.iconWhistle,
        key: whistleIconKey,
        colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
      ),
      alignment: Alignment.centerLeft,
    );
  }
}

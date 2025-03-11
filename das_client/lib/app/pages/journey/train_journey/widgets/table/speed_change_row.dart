import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/speed_change.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class SpeedChangeRow extends BaseRowBuilder<SpeedChange> {
  static const Key kmIndicatorKey = Key('kmIndicator');

  const SpeedChangeRow({
    required super.metadata,
    required super.data,
    super.config,
  });

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Text(data.text ?? ''),
    );
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    final isDarkTheme = SBBBaseStyle.of(context).brightness == Brightness.dark;
    final color = isDarkTheme ? SBBColors.white : SBBColors.black;

    return DASTableCell(
      padding: EdgeInsets.all(sbbDefaultSpacing * 0.25),
      child: SvgPicture.asset(
        AppAssets.iconKmIndicator,
        key: kmIndicatorKey,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
      alignment: Alignment.centerLeft,
    );
  }
}

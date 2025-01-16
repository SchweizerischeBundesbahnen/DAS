import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/whistles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class WhistleRow extends BaseRowBuilder<Whistle> {
  static const Key whistleIconKey = Key('whistle_icon_key');

  const WhistleRow({
    required super.metadata,
    required super.data,
    super.renderData,
  });

  @override
  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell(
      padding: EdgeInsets.all(sbbDefaultSpacing * 0.25),
      child: SvgPicture.asset(
        AppAssets.iconWhistle,
        key: whistleIconKey,
      ),
      alignment: Alignment.centerLeft,
    );
  }
}

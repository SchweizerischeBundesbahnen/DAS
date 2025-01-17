import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/speed_change.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class SpeedChangeRow extends BaseRowBuilder<SpeedChange> {
  static const Key kmIndicatorKey = Key('km_indicator_key');

  SpeedChangeRow({
    required super.metadata,
    required super.data,
    required super.settings,
    super.trackEquipmentRenderData,
  });

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Text(data.text ?? ''),
    );
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell(
      padding: EdgeInsets.all(sbbDefaultSpacing * 0.25),
      child: SvgPicture.asset(
        AppAssets.iconKmIndicator,
        key: kmIndicatorKey,
      ),
      alignment: Alignment.centerLeft,
    );
  }
}

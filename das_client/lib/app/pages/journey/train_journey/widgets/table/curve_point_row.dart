import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/curve_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CurvePointRow extends BaseRowBuilder<CurvePoint> {
  static const Key curvePointIconKey = Key('curve_point_icon_key');

  CurvePointRow({
    required super.metadata,
    required super.data,
    super.trackEquipmentRenderData,
  });

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Text(data.curveType?.localizedName(context) ?? ''),
    );
  }

  @override
  DASTableCell iconsCell1(BuildContext context) {
    return DASTableCell(
      child: SvgPicture.asset(
        AppAssets.iconCurveStart,
        key: curvePointIconKey,
      ),
      alignment: Alignment.center,
    );
  }
}

extension _CurveTypeExtension on CurveType {
  String localizedName(BuildContext context) {
    switch (this) {
      case CurveType.curve:
        return context.l10n.p_train_journey_table_curve_type_curve;
      case CurveType.curveAfterHalt:
        return context.l10n.p_train_journey_table_curve_type_curve_after_halt;
      case CurveType.stationExitCurve:
        return context.l10n.p_train_journey_table_curve_type_station_exit_curve;
      case CurveType.unknown:
        return context.l10n.c_unknown;
    }
  }
}

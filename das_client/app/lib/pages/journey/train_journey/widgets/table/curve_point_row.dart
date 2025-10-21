import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sfera/component.dart';

class CurvePointRow extends CellRowBuilder<CurvePoint> {
  static const Key curvePointIconKey = Key('curvePointIcon');

  CurvePointRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.journeyPosition,
    super.config,
  });

  @override
  DASTableCell localSpeedCell(BuildContext context) => speedCell(data.localSpeeds);

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Text(
        data.curveType?.localizedName(context) ?? '',
        overflow: TextOverflow.ellipsis,
      ),
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

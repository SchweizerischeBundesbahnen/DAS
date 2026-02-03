import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:collection/collection.dart';
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
    final typeText = data.curveType?.localizedName(context) ?? '';
    final startKm = _stringifyKm(data.kilometre.firstOrNull);
    final endKm = _stringifyKm(data.kilometre.length > 1 ? data.kilometre.last : null);

    final text = endKm.isNotEmpty ? '$typeText km $startKm - $endKm' : typeText;

    return DASTableCell(
      child: Text(
        overflow: .ellipsis,
        text,
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
      alignment: .center,
    );
  }

  String _stringifyKm(double? km) {
    if (km == null) return '';
    return km.toStringAsFixed(2).trim();
  }
}

extension _CurveTypeExtension on CurveType {
  String localizedName(BuildContext context) => switch (this) {
    .curve => context.l10n.p_journey_table_curve_type_curve,
    .curveAfterHalt => context.l10n.p_journey_table_curve_type_curve_after_halt,
    .stationExitCurve => context.l10n.p_journey_table_curve_type_station_exit_curve,
    .unknown => context.l10n.c_unknown,
  };
}

import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_table/widgets/table/cell_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class TramAreaRow extends CellRowBuilder<TramArea> {
  static const Key tramAreaIconKey = Key('tramAreaIcon');

  TramAreaRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.journeyPosition,
    super.config,
  });

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Row(
        children: [
          Expanded(child: _kilometreText(context)),
          tramSignalText(context),
        ],
      ),
    );
  }

  Widget tramSignalText(BuildContext context) {
    final amount = data.amountTramSignals > 1 ? data.amountTramSignals : '';
    return Text('$amount ${context.l10n.p_journey_table_tram_area}');
  }

  Widget _kilometreText(BuildContext context) {
    final startKilometre = data.kilometre[0].toStringAsFixed(1);
    final endKilometre = data.endKilometre.toStringAsFixed(1);
    return Text(
      '${context.l10n.p_journey_table_kilometre_label} $startKilometre-$endKilometre',
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell(
      padding: .all(sbbDefaultSpacing * 0.25),
      child: SvgPicture.asset(
        AppAssets.iconTramArea,
        key: tramAreaIconKey,
        colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
      ),
      alignment: Alignment.centerLeft,
    );
  }
}

import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/tram_area.dart';
import 'package:das_client/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class TramAreaRow extends BaseRowBuilder<TramArea> {
  static const Key tramAreaIconKey = Key('tramAreaIcon');

  const TramAreaRow({
    required super.metadata,
    required super.data,
    super.config,
  });

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Row(
        children: [
          Text(
              '${context.l10n.p_train_journey_table_kilometre_label} ${data.kilometre[0].toStringAsFixed(1)}-${data.endKilometre.toStringAsFixed(1)}'),
          Spacer(),
          Text(
              '${data.amountTramSignals > 1 ? data.amountTramSignals : ''} ${context.l10n.p_train_journey_table_tram_area}'),
        ],
      ),
    );
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell(
      padding: EdgeInsets.all(sbbDefaultSpacing * 0.25),
      child: SvgPicture.asset(
        AppAssets.iconTramArea,
        key: tramAreaIconKey,
        colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
      ),
      alignment: Alignment.centerLeft,
    );
  }
}

import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/badge_wrapper.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class AdditionalSpeedRestrictionRow extends CellRowBuilder<AdditionalSpeedRestrictionData> {
  static const Key additionalSpeedRestrictionIconKey = Key('additionSpeedRestrictionIcon');
  static const Color additionalSpeedRestrictionColor = SBBColors.orange;

  AdditionalSpeedRestrictionRow({
    required super.metadata,
    required super.data,
    super.onTap,
    super.config,
  }) : super(rowColor: additionalSpeedRestrictionColor);

  @override
  DASTableCell informationCell(BuildContext context) {
    final kilometreLabel = context.l10n.p_train_journey_table_kilometre_label;
    final fromKilometre = data.kmFrom.toStringAsFixed(3);
    final endKilometre = data.kmTo.toStringAsFixed(3);
    return DASTableCell(
      child: Text(
        '$kilometreLabel $fromKilometre - $kilometreLabel $endKilometre',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    final badgeLabel = data.restrictions.length > 1 ? data.restrictions.length : null;
    return DASTableCell(
      child: BadgeWrapper(
        offset: Offset(-9.0, -14.0),
        label: badgeLabel?.toString(),
        child: SvgPicture.asset(
          AppAssets.iconAdditionalSpeedRestriction,
          key: additionalSpeedRestrictionIconKey,
        ),
      ),
      alignment: Alignment.center,
    );
  }

  @override
  DASTableCell localSpeedCell(BuildContext context) {
    // TODO: What to do with nullable speed
    return DASTableCell(
      child: Text(data.speed.toString()),
      alignment: Alignment.center,
    );
  }
}

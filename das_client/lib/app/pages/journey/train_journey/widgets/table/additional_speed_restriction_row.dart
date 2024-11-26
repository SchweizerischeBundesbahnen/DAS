import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/additional_speed_restriction_data.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdditionalSpeedRestrictionRow extends BaseRowBuilder<AdditionalSpeedRestrictionData> {
  static const Key additionalSpeedRestrictionIconKey = Key('addition_speed_restrction_icon_key');
  static const Color additionalSpeedRestrictionColor = SBBColors.orange;

  AdditionalSpeedRestrictionRow({
    super.height = 44.0,
    required super.metadata,
    required super.data,
  });

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      color: SBBColors.orange,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
              '${context.l10n.p_train_journey_table_kilometre_label} ${data.restriction.kmFrom.toStringAsFixed(1)}-${data.restriction.kmTo.toStringAsFixed(1)}'),
        ],
      ),
    );
  }

  @override
  DASTableCell iconsCell3(BuildContext context) {
    return DASTableCell(child: const SizedBox.shrink(), color: additionalSpeedRestrictionColor);
  }

  @override
  DASTableCell iconsCell1(BuildContext context) {
    return DASTableCell(child: const SizedBox.shrink(), color: additionalSpeedRestrictionColor);
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell(
        color: additionalSpeedRestrictionColor,
        child: SvgPicture.asset(
          AppAssets.iconAdditionalSpeedRestriction,
          key: additionalSpeedRestrictionIconKey,
        ),
        alignment: Alignment.center);
  }

  @override
  DASTableCell graduatedSpeedCell(BuildContext context) {
    return DASTableCell(
      color: additionalSpeedRestrictionColor,
      child: Text(data.restriction.speed.toString()),
      alignment: Alignment.center,
    );
  }
}

import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/additional_speed_restriction_data.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdditionalSpeedRestrictionRow extends BaseRowBuilder<AdditionalSpeedRestrictionData> {
  static const Key additionalSpeedRestrictionIconKey = Key('addition_speed_restriction_icon_key');
  static const Color additionalSpeedRestrictionColor = SBBColors.orange;
  static const double rowHeight = 44.0;

  AdditionalSpeedRestrictionRow({
    required super.metadata,
    required super.data,
    super.height = rowHeight,
  }) : super(rowColor: additionalSpeedRestrictionColor);

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${context.l10n.p_train_journey_table_kilometre_label} ${data.restriction.kmFrom.toStringAsFixed(3)} '
              '- ${context.l10n.p_train_journey_table_kilometre_label} ${data.restriction.kmTo.toStringAsFixed(3)}'),
        ],
      ),
    );
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell(
      child: SvgPicture.asset(
        AppAssets.iconAdditionalSpeedRestriction,
        key: additionalSpeedRestrictionIconKey,
      ),
      alignment: Alignment.center,
    );
  }

  @override
  DASTableCell graduatedSpeedCell(BuildContext context) {
    return DASTableCell(
      child: Text(data.restriction.speed.toString()),
      alignment: Alignment.center,
    );
  }
}

import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/protection_section.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProtectionSectionRow extends BaseRowBuilder<ProtectionSection> {
  static const Key protectionSectionKey = Key('protection_section_key');

  ProtectionSectionRow({
    required super.metadata,
    required super.data,
    required super.settings,
    super.trackEquipmentRenderData,
  }) : super(rowColor: SBBColors.peach);

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${context.l10n.p_train_journey_table_kilometre_label} ${data.kilometre[0].toStringAsFixed(1)}'),
          Spacer(),
          Text('${data.isOptional ? 'F' : ''}${data.isLong ? 'L' : ''}'),
        ],
      ),
    );
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell(
        child: SvgPicture.asset(
          AppAssets.iconProtectionSection,
          key: protectionSectionKey,
        ),
        alignment: Alignment.bottomCenter);
  }
}

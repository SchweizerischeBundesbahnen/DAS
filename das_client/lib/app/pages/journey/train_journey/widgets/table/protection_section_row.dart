import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/protection_section.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProtectionSectionRow extends BaseRowBuilder {
  static const Key stopOnRequestKey = Key('stop_on_request_key');

  ProtectionSectionRow({
    super.height = 44.0,
    required this.metadata,
    required this.protectionSection,
  }) : super(rowColor: SBBColors.peach, kilometre: protectionSection.kilometre);

  final Metadata metadata;
  final ProtectionSection protectionSection;

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
              '${context.l10n.p_train_journey_table_kilometre_label} ${protectionSection.kilometre[0].toStringAsFixed(1)}'),
          Spacer(),
          Text('${protectionSection.isOptional ? 'F' : ''}${protectionSection.isLong ? 'L' : ''}'),
        ],
      ),
    );
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell(
        child: SvgPicture.asset(
          AppAssets.iconProtectionSection,
          key: stopOnRequestKey,
        ),
        alignment: Alignment.bottomCenter);
  }
}

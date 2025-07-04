import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class ProtectionSectionRow extends CellRowBuilder<ProtectionSection> {
  static const Key protectionSectionKey = Key('protectionSection');

  ProtectionSectionRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    super.config,
  }) : super(rowColor: SBBColors.peach);

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _kilometreText(context)),
          Text('${data.isOptional ? 'F' : ''}${data.isLong ? 'L' : ''}'),
        ],
      ),
    );
  }

  Widget _kilometreText(BuildContext context) {
    return Text(
      '${context.l10n.p_train_journey_table_kilometre_label} ${data.kilometre[0].toStringAsFixed(1)}',
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell(
      child: SvgPicture.asset(
        AppAssets.iconProtectionSection,
        key: protectionSectionKey,
      ),
      alignment: Alignment.bottomCenter,
    );
  }
}

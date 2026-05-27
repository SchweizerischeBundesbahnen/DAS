import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/theme/das_colors.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/row/das_table_row_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sfera/component.dart';

class ProtectionSectionRow extends CellRowBuilder<ProtectionSection> {
  static const Key protectionSectionKey = Key('protectionSection');

  ProtectionSectionRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.journeyPosition,
    required super.chevronPosition,
    super.config,
  }) : super(decoration: DASTableRowDecoration(color: DASColors.protectionSectionBackground));

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Row(
        crossAxisAlignment: .end,
        children: [
          Expanded(child: _kilometreText(context)),
          Text('${data.isOptional ? 'F' : ''}${data.isLong ? 'L' : ''}'),
        ],
      ),
    );
  }

  Widget _kilometreText(BuildContext context) {
    return Text(
      '${context.l10n.p_journey_table_kilometre_label} ${data.kilometre[0].toStringAsFixed(1)}',
      overflow: .ellipsis,
    );
  }

  @override
  DASTableCell iconsCell2(BuildContext context) {
    return DASTableCell(
      child: SvgPicture.asset(
        AppAssets.iconProtectionSection,
        key: protectionSectionKey,
      ),
      alignment: .bottomCenter,
    );
  }
}

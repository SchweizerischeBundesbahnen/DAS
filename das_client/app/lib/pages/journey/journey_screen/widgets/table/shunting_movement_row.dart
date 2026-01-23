import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class ShuntingMovementRow extends WidgetRowBuilder<ShuntingMovement> {
  static const Key shuntingMovementStartKey = Key('shuntingMovementStart');
  static const Key shuntingMovementEndKey = Key('shuntingMovementEnd');

  ShuntingMovementRow({
    required super.rowIndex,
    required super.metadata,
    required super.data,
  }) : super(height: 44.0);

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      key: data.isStart ? shuntingMovementStartKey : shuntingMovementEndKey,
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      padding: const EdgeInsets.all(SBBSpacing.medium).copyWith(left: SBBSpacing.large),
      child: Text(_labelText(context), style: DASTextStyles.mediumBold),
    );
  }

  String _labelText(BuildContext context) {
    final trainNumber = metadata.trainIdentification?.trainNumber ?? '';
    return data.isStart
        ? context.l10n.w_shunting_movement_start('${trainNumber}R')
        : context.l10n.w_shunting_movement_end(trainNumber);
  }
}

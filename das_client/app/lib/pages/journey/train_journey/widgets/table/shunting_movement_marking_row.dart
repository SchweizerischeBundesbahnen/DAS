import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class ShuntingMovementMarkingRow extends WidgetRowBuilder<ShuntingMovementMarking> {
  static const Key startMarkingKey = Key('startShuntingMovementMarkingKey');
  static const Key endMarkingKey = Key('endShuntingMovementMarkingKey');

  ShuntingMovementMarkingRow({
    required super.rowIndex,
    required super.metadata,
    required super.data,
  });

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      key: data.isStart ? startMarkingKey : endMarkingKey,
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      padding: EdgeInsets.all(sbbDefaultSpacing).copyWith(left: 24.0),
      child: Text(_labelText(context), style: DASTextStyles.mediumBold),
    );
  }

  String _labelText(BuildContext context) {
    final trainNumber = metadata.trainIdentification?.trainNumber ?? '';
    return data.isStart
        ? context.l10n.w_shunting_movement_marking_start('${trainNumber}R')
        : context.l10n.w_shunting_movement_marking_end(trainNumber);
  }
}

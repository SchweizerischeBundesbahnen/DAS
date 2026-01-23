import 'package:app/i18n/i18n.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

typedef TextFunction = Text Function(String);

class BreakLoadSlipTrainDetailsTable extends StatelessWidget {
  const BreakLoadSlipTrainDetailsTable({required this.formationRunChange, super.key});

  final FormationRunChange formationRunChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _tableRow(
          null,
          context.l10n.p_break_load_slip_train_data_table_header_traction,
          false,
          context.l10n.p_break_load_slip_train_data_table_header_hauled_load,
          false,
          context.l10n.p_break_load_slip_train_data_table_header_formation,
          false,
          style: DASTextStyles.smallLight,
          padding: EdgeInsets.zero,
          alignment: .center,
        ),
        const SizedBox(height: SBBSpacing.xxSmall),
        _tableDivider(context, height: 2),
        _tableRow(
          context.l10n.p_break_load_slip_train_data_table_vmax,
          formationRunChange.formationRun.tractionMaxSpeedInKmh?.toString(),
          formationRunChange.hasChanged(.tractionMaxSpeedInKmh),
          formationRunChange.formationRun.hauledLoadMaxSpeedInKmh?.toString(),
          formationRunChange.hasChanged(.hauledLoadMaxSpeedInKmh),
          formationRunChange.formationRun.formationMaxSpeedInKmh?.toString(),
          formationRunChange.hasChanged(.formationMaxSpeedInKmh),
        ),
        _tableDivider(context),
        _tableRow(
          context.l10n.p_break_load_slip_train_data_table_length,
          (formationRunChange.formationRun.tractionLengthInCm / 100).toString(),
          formationRunChange.hasChanged(.tractionLengthInCm),
          (formationRunChange.formationRun.hauledLoadLengthInCm / 100).toString(),
          formationRunChange.hasChanged(.hauledLoadLengthInCm),
          (formationRunChange.formationRun.formationLengthInCm / 100).toString(),
          formationRunChange.hasChanged(.formationLengthInCm),
        ),
        _tableDivider(context),
        _tableRow(
          context.l10n.p_break_load_slip_train_data_table_weight,
          formationRunChange.formationRun.tractionWeightInT.toString(),
          formationRunChange.hasChanged(.tractionWeightInT),
          formationRunChange.formationRun.hauledLoadWeightInT.toString(),
          formationRunChange.hasChanged(.hauledLoadWeightInT),
          formationRunChange.formationRun.formationWeightInT.toString(),
          formationRunChange.hasChanged(.formationWeightInT),
        ),
        _tableDivider(context),
        _tableRow(
          context.l10n.p_break_load_slip_train_data_table_braked_weight,
          formationRunChange.formationRun.tractionBrakedWeightInT.toString(),
          formationRunChange.hasChanged(.tractionBrakedWeightInT),
          formationRunChange.formationRun.hauledLoadBrakedWeightInT.toString(),
          formationRunChange.hasChanged(.hauledLoadBrakedWeightInT),
          formationRunChange.formationRun.formationBrakedWeightInT.toString(),
          formationRunChange.hasChanged(.formationBrakedWeightInT),
        ),
        _tableDivider(context),
        _tableRow(
          context.l10n.p_break_load_slip_brake_details_holding_force,
          (formationRunChange.formationRun.tractionHoldingForceInHectoNewton / 10).toString(),
          formationRunChange.hasChanged(.tractionHoldingForceInHectoNewton),
          (formationRunChange.formationRun.hauledLoadHoldingForceInHectoNewton / 10).toString(),
          formationRunChange.hasChanged(.hauledLoadHoldingForceInHectoNewton),
          (formationRunChange.formationRun.formationHoldingForceInHectoNewton / 10).toString(),
          formationRunChange.hasChanged(.formationHoldingForceInHectoNewton),
        ),
      ],
    );
  }

  Widget _tableRow(
    String? label,
    String? c1,
    bool hasChangeC1,
    String? c2,
    bool hasChangeC2,
    String? c3,
    bool hasChangeC3, {
    TextStyle? style,
    EdgeInsetsGeometry? padding,
    AlignmentGeometry? alignment,
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: SBBSpacing.xxSmall).copyWith(left: SBBSpacing.xSmall),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label ?? '', style: style ?? DASTextStyles.smallRoman)),
          Expanded(
            flex: 2,
            child: _cell(c1, hasChangeC1, style: style, padding: padding, alignment: alignment),
          ),
          Expanded(
            flex: 2,
            child: _cell(c2, hasChangeC2, style: style, padding: padding, alignment: alignment),
          ),
          Expanded(
            flex: 2,
            child: _cell(c3, hasChangeC3, style: style, padding: padding, alignment: alignment),
          ),
        ],
      ),
    );
  }

  Widget _cell(
    String? text,
    bool hasChange, {
    TextStyle? style,
    EdgeInsetsGeometry? padding,
    AlignmentGeometry? alignment,
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: SBBSpacing.medium),
      child: Align(
        alignment: alignment ?? .centerRight,
        child: _wrappedText(text, hasChange, style: style),
      ),
    );
  }

  Widget _wrappedText(String? text, bool hasChange, {TextStyle? style}) {
    final finalStyle = style ?? (hasChange ? DASTextStyles.smallBold : DASTextStyles.smallRoman);
    final textWidget = Text(text ?? '', style: finalStyle);
    return hasChange
        ? DotIndicator(
            offset: Offset(0, -SBBSpacing.small),
            child: textWidget,
          )
        : textWidget;
  }

  Widget _tableDivider(BuildContext context, {double height = 1}) {
    return Container(
      height: height,
      color: ThemeUtil.isDarkMode(context) ? SBBColors.iron : SBBColors.cloud,
    );
  }
}

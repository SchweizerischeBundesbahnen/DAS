import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/text_util.dart';
import 'package:app/widgets/accordion/accordion.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class UncodedOperationalIndicationRow extends WidgetRowBuilder<UncodedOperationalIndication> {
  UncodedOperationalIndicationRow({
    required super.metadata,
    required super.data,
    required this.isExpanded,
    required this.accordionToggleCallback,
    double? height,
    super.stickyLevel,
    super.config,
    super.identifier,
  }) : super(height: height ?? _calculateHeight(data, isExpanded));

  final bool isExpanded;
  final AccordionToggleCallback accordionToggleCallback;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      child: Accordion(
        // key: ObjectKey(data.identifier), TODO:
        title: context.l10n.c_uncoded_operational_indication,
        body: _contentText(data),
        isExpanded: isExpanded,
        toggleCallback: accordionToggleCallback,
        icon: SBBIcons.form_small,
        margin: EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.5),
        backgroundColor: ThemeUtil.getColor(context, SBBColors.white, SBBColors.charcoal),
      ),
    );
  }

  static Text _contentText(UncodedOperationalIndication data) {
    return Text.rich(TextUtil.parseHtmlText(data.text, DASTextStyles.smallRoman));
  }

  static double _calculateHeight(UncodedOperationalIndication data, bool isExpanded) {
    if (isExpanded) {
      final content = _contentText(data);
      final tp = TextPainter(text: content.textSpan, textDirection: TextDirection.ltr)..layout();
      return Accordion.defaultExpandedHeight + tp.height;
    } else {
      return Accordion.defaultCollapsedHeight;
    }
  }
}

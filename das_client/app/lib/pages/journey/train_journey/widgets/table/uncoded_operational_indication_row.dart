import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/text_util.dart';
import 'package:app/widgets/accordion/accordion.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

// TODO: Show text initially without new lines and add ;
// TODO: Add "show more" functionality
class UncodedOperationalIndicationRow extends WidgetRowBuilder<UncodedOperationalIndication> {
  static const double _verticalMargin = sbbDefaultSpacing * 0.5;

  UncodedOperationalIndicationRow({
    required super.rowIndex,
    required super.metadata,
    required super.data,
    required this.isExpanded,
    required this.accordionToggleCallback,
    required this.addTopMargin,
    this.expandedContent = false,
    double? height,
    super.stickyLevel,
    super.config,
    super.identifier,
  }) : super(height: height ?? _calculateHeight(data, isExpanded, addTopMargin));

  final bool isExpanded;
  final bool expandedContent;
  final bool addTopMargin;
  final AccordionToggleCallback accordionToggleCallback;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      child: Accordion(
        // key: ObjectKey(data.identifier), TODO:
        title: context.l10n.c_uncoded_operational_indication,
        body: _content(data),
        isExpanded: isExpanded,
        toggleCallback: accordionToggleCallback,
        icon: SBBIcons.form_small,
        margin: EdgeInsets.only(
          bottom: _verticalMargin,
          top: addTopMargin ? _verticalMargin : 0.0,
        ),
        backgroundColor: ThemeUtil.getColor(context, SBBColors.white, SBBColors.charcoal),
      ),
    );
  }

  static Text _content(UncodedOperationalIndication data) {
    final textStyle = DASTextStyles.smallRoman;
    // TODO: how to get width?
    // final textWithoutLineBreaks = TextUtil.replaceLineBreaks(data.text);
    // final hasOverflow = TextUtil.hasTextOverflow(textWithoutLineBreaks, 1000, textStyle);
    return Text.rich(TextUtil.parseHtmlText(data.text, textStyle));
  }

  static double _calculateHeight(UncodedOperationalIndication data, bool isExpanded, bool addTopMargin) {
    final margin = _verticalMargin * (addTopMargin ? 2 : 1);
    if (!isExpanded) {
      return Accordion.defaultCollapsedHeight + margin;
    }

    final content = _content(data);
    final tp = TextPainter(text: content.textSpan, textDirection: TextDirection.ltr)..layout();
    return Accordion.defaultExpandedHeight + tp.height + margin;
  }
}

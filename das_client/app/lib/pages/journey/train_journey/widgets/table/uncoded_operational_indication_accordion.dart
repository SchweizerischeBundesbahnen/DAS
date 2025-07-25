import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/train_journey/train_journey_overview.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/text_util.dart';
import 'package:app/widgets/accordion/accordion.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class UncodedOperationalIndicationAccordion extends StatelessWidget {
  static const Key showMoreButtonKey = Key('operationalIndicationShowMoreButton');
  static const Key expandedContentKey = Key('operationalIndicationExpandedContent');
  static const Key collapsedContentKey = Key('operationalIndicationCollapsedContent');

  static const double _verticalMargin = sbbDefaultSpacing * 0.5;
  static const TextStyle _textStyle = DASTextStyles.largeRoman;

  const UncodedOperationalIndicationAccordion({
    required this.isExpanded,
    required this.expandedContent,
    required this.addTopMargin,
    required this.accordionToggleCallback,
    required this.data,
    super.key,
  });

  final UncodedOperationalIndication data;
  final bool isExpanded;
  final bool expandedContent;
  final bool addTopMargin;
  final AccordionToggleCallback accordionToggleCallback;

  @override
  Widget build(BuildContext context) {
    return Accordion(
      key: ObjectKey(data.hashCode),
      title: context.l10n.c_uncoded_operational_indication,
      body: _body(context),
      isExpanded: isExpanded,
      toggleCallback: accordionToggleCallback,
      icon: SBBIcons.form_small,
      margin: EdgeInsets.only(
        bottom: _verticalMargin,
        top: addTopMargin ? _verticalMargin : 0.0,
      ),
      backgroundColor: ThemeUtil.getColor(context, SBBColors.white, SBBColors.charcoal),
    );
  }

  Widget _body(BuildContext context) {
    if (expandedContent) return _contentText(data.combinedText);

    final textWithoutLineBreaks = TextUtil.replaceLineBreaks(data.combinedText);
    final hasOverflow = TextUtil.hasTextOverflow(textWithoutLineBreaks, _accordionContentWidth, _textStyle);
    if (hasOverflow) {
      return Row(
        children: [
          Expanded(child: _contentText(textWithoutLineBreaks, maxLines: 1)),
          _showMoreButton(context),
        ],
      );
    }
    return _contentText(data.combinedText);
  }

  Widget _showMoreButton(BuildContext context) {
    return GestureDetector(
      key: showMoreButtonKey,
      onTap: () => context.read<CollapsibleRowsViewModel>().openWithCollapsedContent(data),
      child: Text(
        context.l10n.c_show_more,
        style: _textStyle.copyWith(
          color: ThemeUtil.getColor(context, SBBColors.granite, SBBColors.graphite),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  static Text _contentText(String text, {int? maxLines}) {
    return Text.rich(
      key: maxLines == null ? expandedContentKey : collapsedContentKey,
      TextUtil.parseHtmlText(text, _textStyle),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }

  static double calculateHeight(
    String text, {
    required bool isExpanded,
    required bool expandedContent,
    required bool addTopMargin,
  }) {
    final margin = _verticalMargin * (addTopMargin ? 2 : 1);
    if (!isExpanded) {
      return Accordion.defaultCollapsedHeight + margin;
    }

    final content = _contentText(text);
    final tp = TextPainter(text: content.textSpan, textDirection: TextDirection.ltr)
      ..layout(maxWidth: _accordionContentWidth);
    return Accordion.defaultExpandedHeight + tp.height + margin;
  }

  static double get _accordionContentWidth =>
      Accordion.contentWidth(outsidePadding: TrainJourneyOverview.horizontalPadding);
}

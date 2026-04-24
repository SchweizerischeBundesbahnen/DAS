import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/journey_overview.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/text_util.dart';
import 'package:app/widgets/accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class UncodedOperationalIndicationAccordion extends StatelessWidget {
  static const Key showMoreTextKey = Key('operationalIndicationShowMoreText');
  static const Key expandedContentKey = Key('operationalIndicationExpandedContent');
  static const Key collapsedContentKey = Key('operationalIndicationCollapsedContent');

  static const double _verticalMargin = SBBSpacing.xSmall;

  static const TextStyle _textStyle = TextStyle(
    fontSize: SBBTextStyles.largeFontSize,
    height: SBBTextStyles.largeFontHeight,
    fontStyle: FontStyle.normal,
    fontWeight: .w400,
    fontFamily: SBBFontFamily.sbbFontRoman,
  );

  const UncodedOperationalIndicationAccordion({
    required this.collapsedState,
    required this.data,
    this.leftPadding = 0,
    super.key,
  });

  final UncodedOperationalIndication data;
  final CollapsedState collapsedState;

  /// used to align content with information cell
  final double leftPadding;

  @override
  Widget build(BuildContext context) {
    final isExpanded = collapsedState != .collapsed;
    final borderRadius = Radius.circular(isExpanded ? SBBSpacing.medium : SBBSpacing.xSmall);
    return Accordion(
      key: ObjectKey(data.hashCode),
      title: context.l10n.c_uncoded_operational_indication,
      body: _body(context),
      isExpanded: isExpanded,
      toggleCallback: () =>
          context.read<CollapsibleRowsViewModel>().toggleRow(data, isContentExpandable: _hasTextOverflow),
      icon: SBBIcons.list_small,
      margin: .only(bottom: _verticalMargin),
      additionalPadding: .only(left: leftPadding),
      backgroundColor: ThemeUtil.getColor(context, SBBColors.cloud, SBBColors.midnight),
      borderRadius: BorderRadius.only(bottomLeft: borderRadius, bottomRight: borderRadius),
    );
  }

  Widget _body(BuildContext context) {
    if (collapsedState == .expandedWithCollapsedContent && _hasTextOverflow) {
      final textWithoutLineBreaks = TextUtil.replaceLineBreaks(data.combinedText);
      return Row(
        children: [
          Expanded(child: _contentText(textWithoutLineBreaks, maxLines: 1)),
          _showMoreText(context),
        ],
      );
    }
    return _contentText(data.combinedText);
  }

  Widget _showMoreText(BuildContext context) {
    return Text(
      key: showMoreTextKey,
      context.l10n.c_show_more,
      style: _textStyle.copyWith(
        color: ThemeUtil.getColor(context, SBBColors.granite, SBBColors.graphite),
        decoration: TextDecoration.underline,
      ),
    );
  }

  bool get _hasTextOverflow {
    final textWithoutLineBreak = TextUtil.replaceLineBreaks(data.combinedText);
    return TextUtil.hasTextOverflow(textWithoutLineBreak, _accordionContentWidth(leftPadding: leftPadding), _textStyle);
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
    required CollapsedState collapsedState,
    required double leftPadding,
  }) {
    final margin = _verticalMargin;
    if (collapsedState == .collapsed) {
      return Accordion.defaultCollapsedHeight + margin;
    }

    final content = _contentText(text);
    final maxLines = collapsedState == .expandedWithCollapsedContent ? 1 : null;
    final tp = TextPainter(text: content.textSpan, textDirection: .ltr, maxLines: maxLines)
      ..layout(maxWidth: _accordionContentWidth(leftPadding: leftPadding));
    return Accordion.defaultExpandedHeight + tp.height + margin;
  }

  static double _accordionContentWidth({required double leftPadding}) =>
      Accordion.contentWidth(margin: JourneyOverview.horizontalPadding, additionalPadding: leftPadding);
}

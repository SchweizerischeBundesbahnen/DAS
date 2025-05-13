import 'package:app/pages/journey/train_journey/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/text_util.dart';
import 'package:app/widgets/accordion/accordion.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

abstract class FootNoteRow<T extends BaseFootNote> extends WidgetRowBuilder<T> {
  // Accordion 30 + 2x8 vertical padding
  static const double _collapsedHeight = 46.0;

  FootNoteRow({
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
      child: SBBGroup(
        margin: EdgeInsets.symmetric(vertical: sbbDefaultSpacing / 2),
        child: Accordion(
          key: ObjectKey(data.identifier),
          title: title(context),
          body: Padding(
            padding: EdgeInsets.fromLTRB(
              sbbDefaultSpacing + 24, // 24 is the width of the icon
              sbbDefaultSpacing * 0.25,
              sbbDefaultSpacing,
              sbbDefaultSpacing * 0.25,
            ),
            child: contentText(data),
          ),
          isExpanded: isExpanded,
          accordionToggleCallback: accordionToggleCallback,
          icon: SBBIcons.form_small,
          backgroundColor: ThemeUtil.getColor(context, SBBColors.white, SBBColors.charcoal),
        ),
      ),
    );
  }

  String title(BuildContext context);

  Text contentText(BaseFootNote data) => _contentText(data);

  static Text _contentText(BaseFootNote data) {
    return Text.rich(TextUtil.parseHtmlText(data.footNote.text, DASTextStyles.smallRoman));
  }

  static double _calculateHeight(BaseFootNote data, bool isExpanded) {
    if (isExpanded) {
      final content = _contentText(data);
      final tp = TextPainter(text: content.textSpan, textDirection: TextDirection.ltr);
      tp.layout();

      return _collapsedHeight + tp.height + sbbDefaultSpacing * 0.5;
    } else {
      return _collapsedHeight;
    }
  }
}

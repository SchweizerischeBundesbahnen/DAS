import 'package:das_client/app/pages/journey/train_journey/widgets/table/widget_row_builder.dart';
import 'package:das_client/app/widgets/accordion/accordion.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/model/journey/base_foot_note.dart';
import 'package:das_client/util/text_util.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

abstract class FootNoteRow<T extends BaseFootNote> extends WidgetRowBuilder<T> {
  // Accordion 30 + 2x8 vertical padding
  static const double _collapsedHeight = 46.0;

  FootNoteRow({
    required super.metadata,
    required super.data,
    required this.isExpanded,
    required this.accordionCallback,
    double? height,
    super.config,
  }) : super(height: height ?? _calculateHeight(data, isExpanded));

  final bool isExpanded;
  final AccordionExpandedCallback accordionCallback;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      color: SBBColors.milk,
      child: SBBGroup(
        margin: EdgeInsets.symmetric(vertical: sbbDefaultSpacing / 2),
        child: Accordion(
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
          accordionCallback: accordionCallback,
          icon: SBBIcons.form_small,
          backgroundColor: SBBColors.cloud,
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

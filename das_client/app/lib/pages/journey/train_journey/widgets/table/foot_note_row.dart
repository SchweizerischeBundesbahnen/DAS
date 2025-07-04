import 'package:app/pages/journey/train_journey/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/text_util.dart';
import 'package:app/widgets/accordion/accordion.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

abstract class FootNoteRow<T extends BaseFootNote> extends WidgetRowBuilder<T> {
  static const double _verticalMargin = sbbDefaultSpacing * 0.5;

  FootNoteRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required this.isExpanded,
    required this.addTopMargin,
    required this.accordionToggleCallback,
    double? height,
    super.stickyLevel,
    super.config,
    super.identifier,
  }) : super(height: height ?? _calculateHeight(data, isExpanded, addTopMargin));

  final bool addTopMargin;
  final bool isExpanded;
  final AccordionToggleCallback accordionToggleCallback;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      child: Accordion(
        key: ObjectKey(data.identifier),
        title: title(context),
        body: contentText(data),
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

  String title(BuildContext context);

  Text contentText(BaseFootNote data) => _contentText(data);

  static Text _contentText(BaseFootNote data) {
    return Text.rich(TextUtil.parseHtmlText(data.footNote.text, DASTextStyles.smallRoman));
  }

  static double _calculateHeight(BaseFootNote data, bool isExpanded, bool addTopMargin) {
    final margin = _verticalMargin * (addTopMargin ? 2 : 1);
    if (!isExpanded) {
      return Accordion.defaultCollapsedHeight + margin;
    }

    final content = _contentText(data);
    final tp = TextPainter(text: content.textSpan, textDirection: TextDirection.ltr)..layout();
    return Accordion.defaultExpandedHeight + tp.height + margin;
  }
}

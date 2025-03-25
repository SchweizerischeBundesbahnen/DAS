import 'package:das_client/app/pages/journey/train_journey/widgets/table/widget_row_builder.dart';
import 'package:das_client/app/widgets/accordion/accordion.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/model/journey/foot_notes.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class OpFootNoteRow extends WidgetRowBuilder<OpFootNotes> {
  static const double _collapsedHeight = 48.0;

  OpFootNoteRow({
    required super.metadata,
    required super.data,
    required this.isExpanded,
    required this.accordionCallback,
    super.config,
  }) : super(height: _calculateHeight(data, isExpanded));

  final bool isExpanded;
  final AccordionExpandedCallback accordionCallback;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      color: SBBColors.milk,
      child: SBBGroup(
        margin: EdgeInsets.symmetric(vertical: sbbDefaultSpacing / 2),
        child: Accordion(
          title: 'RADN',
          body: Padding(
            padding: EdgeInsets.fromLTRB(
              sbbDefaultSpacing + 24, // 24 is the width of the icon
              sbbDefaultSpacing * 0.25,
              sbbDefaultSpacing,
              sbbDefaultSpacing * 0.25,
            ),
            child: _contentText(data),
          ),
          isExpanded: isExpanded,
          accordionCallback: accordionCallback,
          icon: SBBIcons.form_small,
          backgroundColor: SBBColors.cloud,
        ),
      ),
    );
  }

  static Text _contentText(OpFootNotes data) {
    return Text.rich(
      TextSpan(text: data.footNotes.map((it) => it.text).join('\n')),
      style: DASTextStyles.smallRoman,
    );
  }

  static double _calculateHeight(OpFootNotes data, bool isExpanded) {
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

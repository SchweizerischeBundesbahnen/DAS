import 'package:app/pages/journey/journey_screen/journey_overview.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/text_util.dart';
import 'package:app/widgets/accordion/accordion.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class FootNoteAccordion extends StatelessWidget {
  static const double _verticalMargin = SBBSpacing.xSmall;

  const FootNoteAccordion({
    required this.data,
    required this.title,
    required this.addTopMargin,
    required this.isExpanded,
    super.key,
  });

  final BaseFootNote data;
  final String title;
  final bool addTopMargin;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Accordion(
      key: ObjectKey(data.hashCode),
      title: title,
      body: contentText(data),
      isExpanded: isExpanded,
      toggleCallback: () => context.read<CollapsibleRowsViewModel>().toggleRow(data),
      icon: SBBIcons.form_small,
      margin: .only(
        bottom: _verticalMargin,
        top: addTopMargin ? _verticalMargin : 0.0,
      ),
      backgroundColor: ThemeUtil.getColor(context, SBBColors.white, SBBColors.charcoal),
    );
  }

  Text contentText(BaseFootNote data) => _contentText(data);

  static Text _contentText(BaseFootNote data) {
    return Text.rich(TextUtil.parseHtmlText(data.footNote.text, DASTextStyles.largeRoman));
  }

  static double calculateHeight({required BaseFootNote data, required bool isExpanded, required bool addTopMargin}) {
    final margin = _verticalMargin * (addTopMargin ? 2 : 1);
    if (!isExpanded) {
      return Accordion.defaultCollapsedHeight + margin;
    }

    final content = _contentText(data);
    final tp = TextPainter(text: content.textSpan, textDirection: TextDirection.ltr)
      ..layout(maxWidth: _accordionContentWidth);
    return Accordion.defaultExpandedHeight + tp.height + margin;
  }

  static double get _accordionContentWidth => Accordion.contentWidth(outsidePadding: JourneyOverview.horizontalPadding);
}

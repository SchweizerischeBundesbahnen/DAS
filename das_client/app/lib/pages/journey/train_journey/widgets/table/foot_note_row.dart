import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/table/foot_note_accordion.dart';
import 'package:app/pages/journey/train_journey/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/accordion/accordion.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class FootNoteRow<T extends BaseFootNote> extends WidgetRowBuilder<T> {
  FootNoteRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required this.isExpanded,
    required this.addTopMargin,
    required this.accordionToggleCallback,
    super.config,
    super.identifier,
  }) : super(
         stickyLevel: data.stickyLevel,
         height: FootNoteAccordion.calculateHeight(
           data: data,
           isExpanded: isExpanded,
           addTopMargin: addTopMargin,
         ),
       );

  final bool addTopMargin;
  final bool isExpanded;
  final AccordionToggleCallback accordionToggleCallback;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      child: FootNoteAccordion(
        data: data,
        title: data.title(context, metadata),
        addTopMargin: addTopMargin,
        isExpanded: isExpanded,
        accordionToggleCallback: accordionToggleCallback,
      ),
    );
  }
}

// extension

extension FootNoteExtension on BaseFootNote {
  StickyLevel get stickyLevel {
    switch (this) {
      case LineFootNote _:
        return StickyLevel.second;
      default:
        return StickyLevel.none;
    }
  }

  String title(BuildContext context, Metadata metadata) {
    switch (this) {
      case final LineFootNote lineFootNote:
        return _resolveTitle(context, lineFootNote, metadata);
      default:
        return _defaultTitle(context);
    }
  }

  String _resolveTitle(BuildContext context, LineFootNote lineFootNote, Metadata metadata) {
    final identifier = lineFootNote.footNote.identifier;
    if (identifier != null && metadata.lineFootNoteLocations[identifier] != null) {
      final servicePointNames = metadata.lineFootNoteLocations[identifier]!;
      return '${context.l10n.c_radn} ${servicePointNames.first} - ${servicePointNames.last}';
    } else {
      return _defaultTitle(context);
    }
  }

  String _defaultTitle(BuildContext context) {
    if (footNote.refText == 'SIM') {
      return context.l10n.c_radn_sim;
    } else {
      return context.l10n.c_radn;
    }
  }
}

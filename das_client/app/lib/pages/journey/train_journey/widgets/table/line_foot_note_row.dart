import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/table/foot_note_row.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

class LineFootNoteRow extends FootNoteRow<LineFootNote> {
  LineFootNoteRow({
    required super.metadata,
    required super.data,
    required super.isExpanded,
    required super.accordionToggleCallback,
    super.config,
  }) : super(stickyLevel: StickyLevel.second, identifier: data.identifier);

  @override
  String title(BuildContext context) {
    final identifier = data.footNote.identifier;
    if (identifier != null && metadata.lineFootNoteLocations[identifier] != null) {
      final servicePointNames = metadata.lineFootNoteLocations[identifier]!;
      return '${context.l10n.c_radn} ${servicePointNames.first} - ${servicePointNames.last}';
    } else {
      return context.l10n.c_radn;
    }
  }
}

import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/foot_note_row.dart';
import 'package:das_client/model/journey/line_foot_note.dart';
import 'package:flutter/material.dart';

class LineFootNoteRow extends FootNoteRow<LineFootNote> {
  LineFootNoteRow({
    required super.metadata,
    required super.data,
    required super.isExpanded,
    required super.accordionToggleCallback,
    super.config,
  });

  @override
  String title(BuildContext context) {
    final identifier = data.footNote.identifier;
    if (identifier != null && metadata.lineFootNoteLocations[identifier] != null) {
      final servicePointNames = metadata.lineFootNoteLocations[identifier]!;
      return '${context.l10n.c_radn} ${servicePointNames.first.localized} - ${servicePointNames.last.localized}';
    } else {
      return context.l10n.c_radn;
    }
  }
}

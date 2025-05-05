import 'package:app/app/i18n/i18n.dart';
import 'package:app/app/pages/journey/train_journey/widgets/table/foot_note_row.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

class OpFootNoteRow extends FootNoteRow<OpFootNote> {
  OpFootNoteRow({
    required super.metadata,
    required super.data,
    required super.isExpanded,
    required super.accordionToggleCallback,
    super.config,
  });

  @override
  String title(BuildContext context) => context.l10n.c_radn;
}

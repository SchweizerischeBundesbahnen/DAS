import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/foot_note_row.dart';
import 'package:das_client/model/journey/track_foot_note.dart';
import 'package:flutter/material.dart';

class TrackFootNoteRow extends FootNoteRow<TrackFootNote> {
  TrackFootNoteRow({
    required super.metadata,
    required super.data,
    required super.isExpanded,
    required super.accordionToggleCallback,
    super.config,
  });

  @override
  String title(BuildContext context) => context.l10n.c_radn;
}

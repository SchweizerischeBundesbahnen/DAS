import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/connection_track.dart';
import 'package:flutter/material.dart';

class ConnectionTrackRow extends BaseRowBuilder<ConnectionTrack> {
  ConnectionTrackRow({
    required super.metadata,
    required super.data,
  });

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Text(data.text ?? context.l10n.c_connection_track_weiche),
    );
  }
}

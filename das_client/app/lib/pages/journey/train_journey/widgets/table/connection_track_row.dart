import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/line_speed_cell_body.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

class ConnectionTrackRow extends CellRowBuilder<ConnectionTrack> {
  ConnectionTrackRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    super.config,
  });

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Text(
        data.text ?? context.l10n.c_connection_track_weiche,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  ShowSpeedBehavior get showSpeedBehavior => ShowSpeedBehavior.always;
}

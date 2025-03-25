import 'package:das_client/app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/service_point.dart';

/// Data class to hold all the information to chevron animation.
class ChevronAnimationData {
  const ChevronAnimationData({
    required this.offset,
  });

  final double offset;

  static ChevronAnimationData? from(List<BaseData> rows, Journey journey, BaseData currentRow) {
    if (journey.metadata.currentPosition != currentRow && journey.metadata.lastPosition != currentRow) {
      return null;
    }

    if (journey.metadata.lastPosition == null ||
        journey.metadata.currentPosition == null ||
        journey.metadata.lastPosition == journey.metadata.currentPosition) {
      return null;
    }

    final fromIndex = rows.indexOf(journey.metadata.lastPosition!);
    final toIndex = rows.indexOf(journey.metadata.currentPosition!);

    var offset = 0.0;
    for (var i = fromIndex + 1; i <= toIndex; i++) {
      offset += CellRowBuilder.rowHeightForData(rows[i]);
    }

    // Adjust for stopping point circle on start row
    final startRow = rows[fromIndex];
    if (startRow is ServicePoint && startRow.isStop) {
      offset += RouteCellBody.routeCircleSize;
    }

    // Adjust for stopping point circle on end row
    final endRow = rows[toIndex];
    if (endRow is ServicePoint && endRow.isStop) {
      offset -= RouteCellBody.routeCircleSize;
    }

    if (currentRow == journey.metadata.currentPosition) {
      offset *= -1;
    }

    return ChevronAnimationData(offset: offset);
  }
}

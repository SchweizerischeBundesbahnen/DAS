import 'package:app/extension/journey_point_extension.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/chevron_position_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_cell_body.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_chevron.dart';
import 'package:sfera/component.dart';

/// Data class to hold all the information to chevron animation.
class ChevronAnimationData {
  const ChevronAnimationData({
    required this.startOffset,
    required this.endOffset,
    required this.currentPosition,
    this.lastPosition,
  });

  final double startOffset;
  final double endOffset;
  final JourneyPoint currentPosition;
  final JourneyPoint? lastPosition;

  static ChevronAnimationData? from({
    required List<JourneyPoint> journeyPoints,
    required ChevronPositionModel chevronPositionModel,
    required Metadata metadata,
    required BaseData rowData,
    required BrakeSeries? currentBrakeSeries,
    required List<int> expandedGroups,
  }) {
    final currentPosition = chevronPositionModel.currentPosition;
    final lastPosition = chevronPositionModel.lastPosition;
    if (currentPosition == null ||
        lastPosition == null ||
        lastPosition == currentPosition ||
        rowData is! JourneyPoint) {
      return null;
    }

    var toIndex = journeyPoints.indexOfElementOrCollapsedGroup(currentPosition, expandedGroups);
    final currentIndex = journeyPoints.indexOf(rowData);

    var fromIndex = journeyPoints.indexOfElementOrCollapsedGroup(lastPosition, expandedGroups);

    bool reversed = false;
    if (fromIndex > toIndex) {
      reversed = true;
      final temp = fromIndex;
      fromIndex = toIndex;
      toIndex = temp;
    }

    if (fromIndex == -1 || toIndex == -1) {
      return null;
    }

    if (currentIndex < fromIndex || currentIndex > toIndex) {
      return null;
    }

    var startOffset = 0.0;
    var endOffset = 0.0;

    // First row chevron to end of cell
    final startRow = journeyPoints[fromIndex];
    final startRowHeight = CellRowBuilder.rowHeightForData(startRow, currentBrakeSeries);
    final startRowChevronPosition = CellRowBuilder.calculateChevronPosition(startRow, startRowHeight);

    endOffset += startRowHeight - startRowChevronPosition;

    // Full height for all rows in between
    for (var i = fromIndex + 1; i < toIndex; i++) {
      final currentRow = journeyPoints[i];
      final rowHeight = CellRowBuilder.rowHeightForData(currentRow, currentBrakeSeries);
      if (currentIndex == i) {
        // swap startOffset when current cell is passed over
        final chevronPosition = CellRowBuilder.calculateChevronPosition(currentRow, rowHeight);
        endOffset += chevronPosition;
        startOffset = endOffset * -1;
        endOffset = rowHeight - chevronPosition;
      } else {
        endOffset += rowHeight;
      }
    }

    // Last row cell start to chevron position
    final endRow = journeyPoints[toIndex];
    final endRowHeight = CellRowBuilder.rowHeightForData(endRow, currentBrakeSeries);
    final chevronPosition = metadata.journeyEnd == endRow
        ? RouteCellBody.routeCirclePosition - RouteChevron.chevronHeight
        : CellRowBuilder.calculateChevronPosition(endRow, endRowHeight);
    endOffset += chevronPosition;

    if (currentIndex == toIndex && !reversed) {
      startOffset = -endOffset;
      endOffset = 0.0;
    }

    if (reversed) {
      if (currentIndex == toIndex) {
        endOffset = -endOffset;
      } else {
        final temp = startOffset;
        startOffset = endOffset;
        endOffset = temp;
      }
    }

    print(
      'Chevron animation from index $fromIndex to $toIndex with current index $currentIndex, startOffset: $startOffset, endOffset: $endOffset',
    );
    return ChevronAnimationData(
      startOffset: startOffset,
      endOffset: endOffset,
      lastPosition: lastPosition,
      currentPosition: currentPosition,
    );
  }
}

import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/route_chevron.dart';
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

  static ChevronAnimationData? from(
    List<JourneyPoint> rows,
    JourneyPositionModel? journeyPosition,
    Metadata metadata,
    BaseData currentRow,
    BreakSeries? currentBreakSeries,
  ) {
    final currentPosition = journeyPosition?.currentPosition;
    final lastPosition = journeyPosition?.lastPosition;
    if (currentPosition == null || lastPosition == currentPosition || currentRow is! JourneyPoint) {
      return null;
    }

    // handle no position update
    if (lastPosition == null) return _handleNoPositionUpdate(rows, currentPosition, currentRow, currentBreakSeries);

    final fromIndex = rows.indexOf(lastPosition);
    final toIndex = rows.indexOf(currentPosition);

    final currentIndex = rows.indexOf(currentRow);
    if (currentIndex < fromIndex || currentIndex > toIndex) {
      return null;
    }

    var startOffset = 0.0;
    var endOffset = 0.0;

    // First row chevron to end of cell
    final startRow = rows[fromIndex];
    final startRowHeight = CellRowBuilder.rowHeightForData(startRow, currentBreakSeries);
    final startRowChevronPosition = RouteChevron.positionFromHeight(startRowHeight);

    endOffset += startRowHeight - startRowChevronPosition;

    // Full height for all rows in between
    for (var i = fromIndex + 1; i < toIndex; i++) {
      final currentRow = rows[i];
      final rowHeight = CellRowBuilder.rowHeightForData(currentRow, currentBreakSeries);
      if (currentIndex == i) {
        // swap startOffset when current cell is passed over
        final chevronPosition = RouteChevron.positionFromHeight(rowHeight);
        endOffset += chevronPosition;
        startOffset = endOffset * -1;
        endOffset = rowHeight - chevronPosition;
      } else {
        endOffset += rowHeight;
      }
    }

    // Last row cell start to chevron position
    final endRow = rows[toIndex];
    final endRowHeight = CellRowBuilder.rowHeightForData(endRow, currentBreakSeries);
    final chevronPosition = metadata.journeyEnd == endRow
        ? RouteCellBody.routeCirclePosition - RouteChevron.chevronHeight
        : RouteChevron.positionFromHeight(endRowHeight);
    endOffset += chevronPosition;

    if (currentRow == currentPosition) {
      startOffset = -endOffset;
      endOffset = 0.0;
    }

    return ChevronAnimationData(
      startOffset: startOffset,
      endOffset: endOffset,
      lastPosition: lastPosition,
      currentPosition: currentPosition,
    );
  }

  /// returns static animation data for position row and next row overlapped with chevron.
  static ChevronAnimationData? _handleNoPositionUpdate(
    List<JourneyPoint> rows,
    JourneyPoint currentPosition,
    JourneyPoint currentRow,
    BreakSeries? currentBreakSeries,
  ) {
    final positionIndex = rows.indexOf(currentPosition);
    final overlappingRowIndex = positionIndex + 1;
    final currentIndex = rows.indexOf(currentRow);

    if (currentIndex == positionIndex) {
      return ChevronAnimationData(startOffset: 0.0, endOffset: 0.0, currentPosition: currentPosition);
    } else if (currentIndex == overlappingRowIndex) {
      final overlappedRow = rows[overlappingRowIndex];
      final offset = -CellRowBuilder.rowHeightForData(overlappedRow, currentBreakSeries);
      return ChevronAnimationData(startOffset: offset, endOffset: offset, currentPosition: currentPosition);
    }
    return null;
  }
}

import 'package:app/pages/journey/train_journey/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/route_chevron.dart';
import 'package:collection/collection.dart';
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
  final BaseData currentPosition;
  final BaseData? lastPosition;

  static ChevronAnimationData? from(
    List<BaseData> rows,
    Metadata metadata,
    BaseData currentRow,
    BreakSeries? currentBreakSeries,
  ) {
    final currentPosition = metadata.currentPosition;
    final lastPosition = metadata.lastPosition;
    if (currentPosition == null || lastPosition == currentPosition) {
      return null;
    }

    // collapsible rows are not part of the animation
    final filteredRows = rows.whereNot((it) => it.isCollapsible).toList();

    // handle no position update
    if (lastPosition == null) {
      return _initialAnimationData(filteredRows, currentPosition, currentRow, currentBreakSeries);
    }

    final fromIndex = filteredRows.indexOf(lastPosition);
    final toIndex = filteredRows.indexOf(currentPosition);
    final calculateToIndex = toIndex + 1; // overlapping of next row

    final currentIndex = filteredRows.indexOf(currentRow);
    if (currentIndex < fromIndex || currentIndex > calculateToIndex) {
      return null;
    }

    var startOffset = 0.0;
    var endOffset = 0.0;

    // First row chevron to end of cell
    final startRow = filteredRows[fromIndex];
    final startRowHeight = CellRowBuilder.rowHeightForData(startRow, currentBreakSeries);
    final startRowChevronPosition = RouteChevron.positionFromHeight(startRowHeight);

    endOffset += startRowHeight - startRowChevronPosition;

    // Full height for all rows in between
    for (var i = fromIndex + 1; i < toIndex; i++) {
      final currentRow = filteredRows[i];
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
    final endRow = filteredRows[toIndex];
    final endRowHeight = CellRowBuilder.rowHeightForData(endRow, currentBreakSeries);
    final chevronPosition = metadata.routeEnd == endRow
        ? RouteCellBody.routeCirclePosition - RouteChevron.chevronHeight
        : RouteChevron.positionFromHeight(endRowHeight);
    endOffset += chevronPosition;

    if (currentRow == currentPosition) {
      startOffset = -endOffset;
      endOffset = 0.0;
    }

    // show end of overlapping chevron on row after current position
    if (currentIndex == calculateToIndex) {
      final overlappedRow = filteredRows[calculateToIndex];
      final overlappedRowHeight = CellRowBuilder.rowHeightForData(overlappedRow, currentBreakSeries);
      startOffset = -endOffset - overlappedRowHeight;
      endOffset = -overlappedRowHeight;
    }

    return ChevronAnimationData(
      startOffset: startOffset,
      endOffset: endOffset,
      lastPosition: lastPosition,
      currentPosition: currentPosition,
    );
  }

  /// returns static animation data for position row and next row overlapped with chevron.
  static ChevronAnimationData? _initialAnimationData(
    List<BaseData> filteredRows,
    BaseData currentPosition,
    BaseData currentRow,
    BreakSeries? currentBreakSeries,
  ) {
    final positionIndex = filteredRows.indexOf(currentPosition);
    final overlappingRowIndex = positionIndex + 1;
    final currentIndex = filteredRows.indexOf(currentRow);

    if (currentIndex == positionIndex) {
      return ChevronAnimationData(startOffset: 0.0, endOffset: 0.0, currentPosition: currentPosition);
    } else if (currentIndex == overlappingRowIndex) {
      final overlappedRow = filteredRows[overlappingRowIndex];
      final offset = -CellRowBuilder.rowHeightForData(overlappedRow, currentBreakSeries);
      return ChevronAnimationData(startOffset: offset, endOffset: offset, currentPosition: currentPosition);
    }
    return null;
  }
}

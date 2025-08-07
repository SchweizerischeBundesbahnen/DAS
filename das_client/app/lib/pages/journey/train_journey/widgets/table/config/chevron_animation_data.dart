import 'package:app/pages/journey/train_journey/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/route_chevron.dart';
import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

/// Data class to hold all the information to chevron animation.
class ChevronAnimationData {
  const ChevronAnimationData({
    required this.startOffset,
    required this.endOffset,
    required this.lastPosition,
    required this.currentPosition,
  });

  final double startOffset;
  final double endOffset;
  final BaseData lastPosition;
  final BaseData currentPosition;

  static ChevronAnimationData? from(
    List<BaseData> rows,
    Journey journey,
    BaseData currentRow,
    BreakSeries? currentBreakSeries,
  ) {
    // TODO: Handle chevron without position update
    if (journey.metadata.lastPosition == null ||
        journey.metadata.currentPosition == null ||
        journey.metadata.lastPosition == journey.metadata.currentPosition) {
      return null;
    }

    // Collapsible rows are not part of the animation
    final filteredRows = rows.whereNot((it) => it.isCollapsible).toList();

    final fromIndex = filteredRows.indexOf(journey.metadata.lastPosition!);
    final toIndex = filteredRows.indexOf(journey.metadata.currentPosition!);
    final calculateToIndex = toIndex + 1; // overlapping of next row

    final currentIndex = filteredRows.indexOf(currentRow);
    if (currentIndex < fromIndex || currentIndex > calculateToIndex) {
      return null;
    }

    var startOffset = 0.0;
    var endOffset = 0.0;

    // TODO: Handle chevron position for start or end of route
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
    final endRowChevronPosition = RouteChevron.positionFromHeight(endRowHeight);
    endOffset += endRowChevronPosition;

    if (currentRow == journey.metadata.currentPosition) {
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
      lastPosition: journey.metadata.lastPosition!,
      currentPosition: journey.metadata.currentPosition!,
    );
  }
}

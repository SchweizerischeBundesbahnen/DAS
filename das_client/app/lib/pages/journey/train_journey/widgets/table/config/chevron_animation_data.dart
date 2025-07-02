import 'package:app/extension/base_data_extension.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

/// Data class to hold all the information to chevron animation.
class ChevronAnimationData {
  const ChevronAnimationData({
    required this.startOffset,
    required this.endOffset,
    required this.lastPosition,
    required this.currenPosition,
  });

  final double startOffset;
  final double endOffset;
  final BaseData lastPosition;
  final BaseData currenPosition;

  static ChevronAnimationData? from(
    List<BaseData> rows,
    Journey journey,
    BaseData currentRow,
    BreakSeries? currentBreakSeries,
  ) {
    if (journey.metadata.lastPosition == null ||
        journey.metadata.currentPosition == null ||
        journey.metadata.lastPosition == journey.metadata.currentPosition) {
      return null;
    }

    // Footnotes are not part of the animation
    final filteredRows = rows.whereNot((it) => it is BaseFootNote).toList();

    final fromIndex = filteredRows.indexOf(journey.metadata.lastPosition!);
    final toIndex = filteredRows.indexOf(journey.metadata.currentPosition!);

    final currentIndex = filteredRows.indexOf(currentRow);
    if (currentIndex < fromIndex || currentIndex > toIndex) {
      return null;
    }

    var startOffset = 0.0;
    var endOffset = 0.0;

    // First row chevron to end of cell
    final startRow = filteredRows[fromIndex];
    final startRowHeight = CellRowBuilder.rowHeightForData(startRow, currentBreakSeries);
    final startRowChevronPosition = startRow.chevronPosition;

    endOffset += startRowHeight - startRowChevronPosition;

    // Full height for all rows in between
    for (var i = fromIndex + 1; i < toIndex; i++) {
      final currentRow = filteredRows[i];
      final rowHeight = CellRowBuilder.rowHeightForData(currentRow, currentBreakSeries);
      if (currentIndex == i) {
        // swap startOffset when current cell is passed over
        final chevronPosition = currentRow.chevronPosition;
        endOffset += chevronPosition;
        startOffset = endOffset * -1;
        endOffset = rowHeight - chevronPosition;
      } else {
        endOffset += rowHeight;
      }
    }

    // Last row cell start to chevron position
    final endRow = filteredRows[toIndex];
    final endRowChevronPosition = endRow.chevronPosition;
    endOffset += endRowChevronPosition;

    if (currentRow == journey.metadata.currentPosition) {
      startOffset = -endOffset;
      endOffset = 0.0;
    }

    return ChevronAnimationData(
      startOffset: startOffset,
      endOffset: endOffset,
      lastPosition: journey.metadata.lastPosition!,
      currenPosition: journey.metadata.currentPosition!,
    );
  }
}

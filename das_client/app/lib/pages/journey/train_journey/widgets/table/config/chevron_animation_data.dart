import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
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

    // Adjust for stopping point circle on start row
    final startRow = filteredRows[fromIndex];
    if (startRow is ServicePoint && startRow.isStop) {
      endOffset += RouteCellBody.routeCircleSize;
    }

    for (var i = fromIndex + 1; i <= toIndex; i++) {
      endOffset += CellRowBuilder.rowHeightForData(filteredRows[i], currentBreakSeries);
      if (currentIndex == i) {
        startOffset = endOffset * -1;
        endOffset = 0.0;
      }
    }

    // Adjust for stopping point circle on end row
    final endRow = filteredRows[toIndex];
    if (endRow is ServicePoint && endRow.isStop) {
      endOffset -= RouteCellBody.routeCircleSize;
    }

    if (currentRow == journey.metadata.currentPosition) {
      startOffset -= endOffset;
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

import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/journey.dart';

/// Data class to hold all the information to chevron animation.
class ChevronAnimationData {
  const ChevronAnimationData({
    required this.offset,
    required this.durationMs,
  });

  final double offset;
  final int durationMs;

  static ChevronAnimationData? from(List<BaseData> rows, Journey journey, BaseData currentRow) {
    if (journey.metadata.currentPosition != currentRow ||
        journey.metadata.lastPosition == null ||
        journey.metadata.currentPosition == null ||
        journey.metadata.lastPosition == journey.metadata.currentPosition) {
      return null;
    }

    final fromIndex = rows.indexOf(journey.metadata.lastPosition!);
    final toIndex = rows.indexOf(journey.metadata.currentPosition!);

    var offset = 0.0;
    for (var i = fromIndex + 1; i <= toIndex; i++) {
      offset += BaseRowBuilder.rowHeightForData(rows[i]);
    }
    return ChevronAnimationData(offset: offset, durationMs: 500);
  }
}

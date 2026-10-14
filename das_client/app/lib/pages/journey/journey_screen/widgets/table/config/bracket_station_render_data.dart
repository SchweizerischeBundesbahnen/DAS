import 'package:core_data/component.dart';
import 'package:sfera/component.dart';

/// Data class to hold all the information to visualize bracket stations.
class const BracketStationRenderData({
  final String? stationAbbreviation,
  final bool isStart = false,
}) {
  static BracketStationRenderData? from({required BaseData data, required Metadata metadata}) {
    final bracketStationSegments = metadata.bracketStationSegments;
    final segment = bracketStationSegments.appliesToOrder(data.order).firstOrNull;
    if (segment == null) return null;

    return BracketStationRenderData(
      stationAbbreviation: segment.mainStationAbbreviation,
      isStart: data.order == segment.startOrder && data is ServicePoint,
    );
  }
}

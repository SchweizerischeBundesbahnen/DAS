import 'package:app/model/journey/base_data.dart';
import 'package:app/model/journey/metadata.dart';
import 'package:app/model/journey/segment.dart';

/// Data class to hold all the information to visualize bracket stations.
class BracketStationRenderData {
  const BracketStationRenderData({
    this.stationAbbreviation,
    this.isStart = false,
  });

  final String? stationAbbreviation;
  final bool isStart;

  static BracketStationRenderData? from(BaseData data, Metadata metadata) {
    final bracketStationSegments = metadata.bracketStationSegments;
    final segment = bracketStationSegments.appliesToOrder(data.order).firstOrNull;
    if (segment == null) return null;

    return BracketStationRenderData(
      stationAbbreviation: segment.mainStationAbbreviation,
      isStart: data.order == segment.startOrder,
    );
  }
}

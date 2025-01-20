import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/bracket_station_segment.dart';
import 'package:das_client/model/journey/metadata.dart';

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
    final segment = bracketStationSegments.appliesToOrder(data.order);
    if (segment == null) return null;

    return BracketStationRenderData(
      stationAbbreviation: segment.mainStationAbbreviation,
      isStart: data.order == segment.startOrder,
    );
  }
}

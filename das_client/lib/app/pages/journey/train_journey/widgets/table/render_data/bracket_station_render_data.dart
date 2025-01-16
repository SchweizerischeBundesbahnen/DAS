import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/bracket_station_segment.dart';
import 'package:das_client/model/journey/metadata.dart';

/// Data class to hold all the information to visualize bracket stations.
class BracketStationRenderData {
  const BracketStationRenderData({
    this.stationAbbreviation,
    this.isStart = false,
    this.isWithin = false,
  });

  final String? stationAbbreviation;
  final bool isStart;
  final bool isWithin;

  factory BracketStationRenderData.from(List<BaseData> rowData, Metadata metadata, int index) {
    final data = rowData[index];
    final bracketStationSegments = metadata.bracketStationSegments;
    final segment = bracketStationSegments.appliesToOrder(data.order);
    if (segment == null) return BracketStationRenderData();

    return BracketStationRenderData(
      stationAbbreviation: segment.mainStationAbbreviation,
      isStart: data.order == segment.startOrder,
      isWithin: true,
    );
  }
}

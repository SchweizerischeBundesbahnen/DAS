import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/cab_signaling.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/track_equipment_segment.dart';

/// Data class to hold all the information to visualize the track equipment.
class TrackEquipmentRenderData {
  const TrackEquipmentRenderData({
    this.cumulativeHeight = 0.0,
    this.isStart = false,
    this.isEnd = false,
    this.isConventionalExtendedSpeedBorder = false,
    this.trackEquipmentType,
  });

  final double cumulativeHeight;
  final bool isStart;
  final bool isEnd;
  final bool isConventionalExtendedSpeedBorder;
  final TrackEquipmentType? trackEquipmentType;

  static TrackEquipmentRenderData? from(List<BaseData> rowData, Metadata metadata, int index) {
    final data = rowData[index];
    final nonStandardTrackEquipmentSegments = metadata.nonStandardTrackEquipmentSegments;
    final matchingSegment = nonStandardTrackEquipmentSegments.appliesToOrder(data.order).firstOrNull;
    if (matchingSegment == null) return null;

    return TrackEquipmentRenderData(
      trackEquipmentType: matchingSegment.type,
      cumulativeHeight: _calculateTrackEquipmentCumulativeHeight(rowData, metadata, matchingSegment, index),
      isConventionalExtendedSpeedBorder: _isConventionalExtendedSpeedBorder(rowData, metadata, index),
      isStart: _isStart(data, matchingSegment, rowData),
      isEnd: _isEnd(data, matchingSegment, rowData),
    );
  }

  /// checks if current data is the end of the [NonStandardTrackEquipmentSegment] for the given rowData
  static bool _isEnd(BaseData data, NonStandardTrackEquipmentSegment segment, List<BaseData> rowData) {
    if (data is CABSignaling && data.isEnd) {
      return true;
    } else if (segment.isEtcsL2Segment) {
      // ETCS level 2 end is marked by CABSignaling
      return false;
    }

    return rowData.inNonStandardTrackEquipmentSegment(segment).last == data;
  }

  /// checks if current data is the start of the [NonStandardTrackEquipmentSegment] for the given rowData
  static bool _isStart(BaseData data, NonStandardTrackEquipmentSegment segment, List<BaseData> rowData) {
    if (data is CABSignaling && data.isStart) {
      return true;
    } else if (segment.isEtcsL2Segment) {
      // ETCS level 2 start is marked by CABSignaling
      return false;
    }

    return rowData.inNonStandardTrackEquipmentSegment(segment).first == data;
  }

  /// calculates the cumulative height of the track equipment "line" of previous rows with the same type as given [segment].
  static double _calculateTrackEquipmentCumulativeHeight(
      List<BaseData> rowData, Metadata metadata, NonStandardTrackEquipmentSegment segment, int index) {
    var cumulativeHeight = 0.0;
    var searchIndex = index - 1;
    while (searchIndex >= 0) {
      final data = rowData[searchIndex];
      final segment = metadata.nonStandardTrackEquipmentSegments.appliesToOrder(data.order).firstOrNull;

      if (segment == null || segment.type != segment.type) {
        break;
      }

      cumulativeHeight += _rowHeight(data, segment, rowData);

      // if is conventional extended speed border, reduce by it's height as it is not part of the dashed line.
      if (_isConventionalExtendedSpeedBorder(rowData, metadata, searchIndex)) {
        cumulativeHeight -= TrackEquipmentCellBody.conventionalExtendedSpeedBorderSpace;
      }

      searchIndex--;
    }
    return cumulativeHeight;
  }

  /// returns height of track equipment "line" for given row
  static double _rowHeight(BaseData data, NonStandardTrackEquipmentSegment segment, List<BaseData> rowData) {
    late double rowHeight;
    switch (data.type) {
      case Datatype.servicePoint:
        rowHeight = ServicePointRow.rowHeight;
        break;
      default:
        rowHeight = BaseRowBuilder.rowHeight;
    }

    final isStartOrEnd = _isStart(data, segment, rowData) || _isEnd(data, segment, rowData);

    return isStartOrEnd ? rowHeight / 2 : rowHeight;
  }

  /// checks if between current and previous track equipment is a border between extended and conventional speed.
  static bool _isConventionalExtendedSpeedBorder(List<BaseData> rowData, Metadata metadata, int index) {
    if (index < 1) return false;

    final nonStandardTrackEquipmentSegments = metadata.nonStandardTrackEquipmentSegments;
    final currentData = rowData[index];
    final previousData = rowData[index - 1];

    final trackEquipment = nonStandardTrackEquipmentSegments.appliesToOrder(currentData.order).firstOrNull;
    final previousTrackEquipment = nonStandardTrackEquipmentSegments.appliesToOrder(previousData.order).firstOrNull;
    if (previousTrackEquipment == null || trackEquipment == null) return false;

    return (trackEquipment.isConventionalSpeed && previousTrackEquipment.isExtendedSpeed) ||
        (trackEquipment.isExtendedSpeed && previousTrackEquipment.isConventionalSpeed);
  }
}

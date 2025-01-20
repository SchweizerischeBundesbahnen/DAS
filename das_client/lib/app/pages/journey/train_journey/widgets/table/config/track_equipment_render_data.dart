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
    this.isCABStart = false,
    this.isCABEnd = false,
    this.isConventionalExtendedSpeedBorder = false,
    this.trackEquipmentType,
  });

  final double cumulativeHeight;
  final bool isCABStart;
  final bool isCABEnd;
  final bool isConventionalExtendedSpeedBorder;
  final TrackEquipmentType? trackEquipmentType;

  static TrackEquipmentRenderData? from(List<BaseData> rowData, Metadata metadata, int index) {
    final data = rowData[index];
    final nonStandardTrackEquipmentSegments = metadata.nonStandardTrackEquipmentSegments;
    final trackEquipment = nonStandardTrackEquipmentSegments.appliesToOrder(data.order).firstOrNull;
    if (trackEquipment == null || !trackEquipment.isEtcsL2Segment) return null;

    return TrackEquipmentRenderData(
      trackEquipmentType: trackEquipment.type,
      cumulativeHeight: _calculateTrackEquipmentCumulativeHeight(rowData, metadata, trackEquipment, index),
      isConventionalExtendedSpeedBorder: _isConventionalExtendedSpeedBorder(rowData, metadata, index),
      isCABStart: data is CABSignaling ? data.isStart : false,
      isCABEnd: data is CABSignaling ? data.isEnd : false,
    );
  }

  /// calculates the cumulative height of the track equipment "line" of previous rows with the same type as given [trackEquipment].
  static double _calculateTrackEquipmentCumulativeHeight(
      List<BaseData> rowData, Metadata metadata, NonStandardTrackEquipmentSegment trackEquipment, int index) {
    var cumulativeHeight = 0.0;
    var searchIndex = index - 1;
    while (searchIndex >= 0) {
      final data = rowData[searchIndex];
      final testTrackEquipment = metadata.nonStandardTrackEquipmentSegments.appliesToOrder(data.order).firstOrNull;

      if (testTrackEquipment == null || testTrackEquipment.type != trackEquipment.type) {
        break;
      }

      cumulativeHeight += _rowHeight(data);

      // if is conventional extended speed border, reduce by it's height as it is not part of the dashed line.
      if (_isConventionalExtendedSpeedBorder(rowData, metadata, searchIndex)) {
        cumulativeHeight -= TrackEquipmentCellBody.conventionalExtendedSpeedBorderSpace;
      }

      searchIndex--;
    }
    return cumulativeHeight;
  }

  /// returns height of track equipment "line" for given row
  static double _rowHeight(BaseData data) {
    switch (data.type) {
      case Datatype.servicePoint:
        return ServicePointRow.rowHeight;
      case Datatype.cabSignaling:
        return (data as CABSignaling).isStart ? BaseRowBuilder.rowHeight / 2 : BaseRowBuilder.rowHeight;
      default:
        return BaseRowBuilder.rowHeight;
    }
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

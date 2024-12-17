import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/cab_signaling.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/track_equipment.dart';

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

  factory TrackEquipmentRenderData.from(Journey journey, int index) {
    final nonStandardTrackEquipmentSegments = journey.metadata.nonStandardTrackEquipmentSegments;
    final trackEquipment = nonStandardTrackEquipmentSegments.appliesToOrder(journey.data[index].order).firstOrNull;
    if (trackEquipment == null || !trackEquipment.isEtcsL2Segment) return TrackEquipmentRenderData();

    return TrackEquipmentRenderData(
      trackEquipmentType: trackEquipment.type,
      cumulativeHeight: _calculateTrackEquipmentCumulativeHeight(journey, trackEquipment, index),
      isConventionalExtendedSpeedBorder: _isConventionalExtendedSpeedBorder(journey, index),
    );
  }

  TrackEquipmentRenderData copyWith({
    double? cumulativeHeight,
    bool? isCABStart,
    bool? isCABEnd,
    bool? isConventionalExtendedSpeedBorder,
    TrackEquipmentType? trackEquipmentType,
  }) =>
      TrackEquipmentRenderData(
        cumulativeHeight: cumulativeHeight ?? this.cumulativeHeight,
        isCABStart: isCABStart ?? this.isCABStart,
        isCABEnd: isCABEnd ?? this.isCABEnd,
        isConventionalExtendedSpeedBorder: isConventionalExtendedSpeedBorder ?? this.isConventionalExtendedSpeedBorder,
        trackEquipmentType: trackEquipmentType ?? this.trackEquipmentType,
      );

  /// calculates the cumulative height of the track equipment "line" of previous rows with the same type as given [trackEquipment].
  static double _calculateTrackEquipmentCumulativeHeight(
      Journey journey, NonStandardTrackEquipmentSegment trackEquipment, int index) {
    var cumulativeHeight = 0.0;
    var searchIndex = index - 1;
    while (searchIndex >= 0) {
      final data = journey.data[searchIndex];
      final testTrackEquipment =
          journey.metadata.nonStandardTrackEquipmentSegments.appliesToOrder(data.order).firstOrNull;

      if (testTrackEquipment == null || testTrackEquipment.type != trackEquipment.type) {
        break;
      }

      cumulativeHeight += _rowHeight(data);

      // if is conventional extended speed border, reduce by it's height as it is not part of the dashed line.
      if (_isConventionalExtendedSpeedBorder(journey, searchIndex)) {
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
  static bool _isConventionalExtendedSpeedBorder(Journey journey, int index) {
    if (index < 1) return false;

    final nonStandardTrackEquipmentSegments = journey.metadata.nonStandardTrackEquipmentSegments;
    final currentData = journey.data[index];
    final previousData = journey.data[index - 1];

    final trackEquipment = nonStandardTrackEquipmentSegments.appliesToOrder(currentData.order).firstOrNull;
    final previousTrackEquipment = nonStandardTrackEquipmentSegments.appliesToOrder(previousData.order).firstOrNull;
    if (previousTrackEquipment == null || trackEquipment == null) return false;

    return (trackEquipment.isConventionalSpeed && previousTrackEquipment.isExtendedSpeed) ||
        (trackEquipment.isExtendedSpeed && previousTrackEquipment.isConventionalSpeed);
  }
}

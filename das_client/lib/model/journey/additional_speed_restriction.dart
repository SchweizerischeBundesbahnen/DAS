import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/segment.dart';
import 'package:das_client/model/journey/track_equipment_segment.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
class AdditionalSpeedRestriction {
  const AdditionalSpeedRestriction({
    required this.kmFrom,
    required this.kmTo,
    required this.orderFrom,
    required this.orderTo,
    this.speed,
  });

  final double kmFrom;
  final double kmTo;
  final int orderFrom;
  final int orderTo;
  final int? speed;

  bool needsEndMarker(List<BaseData> journeyData) {
    return journeyData.where((it) => it.order >= orderFrom && it.order <= orderTo).length > 1;
  }

  /// Checks if this ASR should be displayed in the train journey.
  ///
  /// returns false if ASR from 40km/h is completely in the ETCS Level 2 area. Otherwise true
  bool isDisplayed(List<NonStandardTrackEquipmentSegment> trackEquipmentSegments) {
    final insideEtcsL2Segments = trackEquipmentSegments
        .where((segment) => segment.type.isEtcsL2)
        .appliesToOrderRange(orderFrom, orderTo)
        .isNotEmpty;

    if (insideEtcsL2Segments && speed != null && speed! >= 40) {
      return false;
    }

    return true;
  }

  @override
  String toString() {
    return 'AdditionalSpeedRestriction(kmFrom: $kmFrom, kmTo: $kmTo, orderFrom: $orderFrom, orderTo: $orderTo, speed: $speed)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdditionalSpeedRestriction &&
          runtimeType == other.runtimeType &&
          kmFrom == other.kmFrom &&
          kmTo == other.kmTo &&
          orderFrom == other.orderFrom &&
          orderTo == other.orderTo &&
          speed == other.speed;

  @override
  int get hashCode => kmFrom.hashCode ^ kmTo.hashCode ^ orderFrom.hashCode ^ orderTo.hashCode ^ speed.hashCode;
}

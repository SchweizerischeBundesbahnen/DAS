import 'package:meta/meta.dart';
import 'package:sfera/src/model/journey/base_data.dart';
import 'package:sfera/src/model/journey/segment.dart';
import 'package:sfera/src/model/journey/track_equipment_segment.dart';
import 'package:sfera/src/model/localized_string.dart';

@sealed
@immutable
class AdditionalSpeedRestriction {
  const AdditionalSpeedRestriction({
    required this.kmFrom,
    required this.kmTo,
    required this.orderFrom,
    required this.orderTo,
    this.restrictionFrom,
    this.restrictionUntil,
    this.speed,
    this.reason,
  });

  final double kmFrom;
  final double kmTo;
  final int orderFrom;
  final int orderTo;
  final DateTime? restrictionFrom;
  final DateTime? restrictionUntil;
  final int? speed;
  final LocalizedString? reason;

  bool needsEndMarker(List<BaseData> journeyData) =>
      journeyData.where((it) => it.order >= orderFrom && it.order <= orderTo).isNotEmpty;

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
    return 'AdditionalSpeedRestriction{kmFrom: $kmFrom, kmTo: $kmTo, orderFrom: $orderFrom, orderTo: $orderTo, restrictionFrom: $restrictionFrom, restrictionUntil: $restrictionUntil, speed: $speed, reason: $reason}';
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
          reason == other.reason &&
          restrictionFrom == other.restrictionFrom &&
          restrictionUntil == other.restrictionUntil &&
          speed == other.speed;

  @override
  int get hashCode =>
      kmFrom.hashCode ^
      kmTo.hashCode ^
      orderFrom.hashCode ^
      orderTo.hashCode ^
      speed.hashCode ^
      reason.hashCode ^
      restrictionFrom.hashCode ^
      restrictionUntil.hashCode;
}

extension T on Iterable<AdditionalSpeedRestriction> {
  AdditionalSpeedRestriction get getLowestByOrderFrom {
    return reduce((current, next) => current.orderFrom < next.orderFrom ? current : next);
  }

  AdditionalSpeedRestriction get getHighestByOrderTo {
    return reduce((current, next) => current.orderTo <= next.orderTo ? next : current);
  }

  int? get minSpeed => where(
    (restriction) => restriction.speed != null,
  ).reduce((current, next) => current.speed! < next.speed! ? current : next).speed;
}

import 'package:collection/collection.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class CurvePoint extends JourneyPoint {
  const CurvePoint({
    required super.order,
    required super.kilometre,
    super.localSpeeds,
    this.curvePointType,
    this.curveType,
    this.text,
    this.comment,
  }) : super(dataType: .curvePoint);

  final CurvePointType? curvePointType;
  final CurveType? curveType;
  final String? text;
  final String? comment;

  @override
  OrderPriority get orderPriority => .curve;

  @override
  String toString() {
    return 'CurvePoint{order: $order, kilometre: $kilometre, curvePointType: $curvePointType, curveType: $curveType, text: $text, comment: $comment}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurvePoint &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre) &&
          curvePointType == other.curvePointType &&
          curveType == other.curveType &&
          text == other.text &&
          comment == other.comment &&
          DeepCollectionEquality().equals(localSpeeds, other.localSpeeds);

  @override
  int get hashCode =>
      dataType.hashCode ^
      order.hashCode ^
      Object.hashAll(kilometre) ^
      curvePointType.hashCode ^
      curveType.hashCode ^
      text.hashCode ^
      comment.hashCode ^
      Object.hashAll(localSpeeds ?? []);
}

/// marks the beginning and the end of a curve
enum CurvePointType {
  begin,
  end,
  unknown
  ;

  factory CurvePointType.from(String value) =>
      values.firstWhere((e) => e.name.toLowerCase() == value.toLowerCase(), orElse: () => .unknown);
}

/// Type of curve. Is provided only if type is [CurvePointType.begin]
enum CurveType {
  /// begins on the line and ends on the line or a station or a halt
  curve,

  /// begins in a station
  stationExitCurve,

  /// begins at an halt
  curveAfterHalt,
  unknown
  ;

  factory CurveType.from(String value) =>
      values.firstWhere((e) => e.name.toLowerCase() == value.toLowerCase(), orElse: () => .unknown);
}

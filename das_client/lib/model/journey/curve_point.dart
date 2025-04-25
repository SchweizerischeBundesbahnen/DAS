import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/order_priority.dart';

class CurvePoint extends BaseData {
  const CurvePoint({
    required super.order,
    required super.kilometre,
    super.localSpeedData,
    this.curvePointType,
    this.curveType,
    this.text,
    this.comment,
  }) : super(type: Datatype.curvePoint);

  final CurvePointType? curvePointType;
  final CurveType? curveType;
  final String? text;
  final String? comment;

  @override
  OrderPriority get orderPriority => OrderPriority.curve;

  @override
  String toString() {
    return "CurvePoint(order: $order, kilometre: $kilometre, curvePointType: $curvePointType, curveType: $curveType, text: '$text', comment: '$comment')";
  }
}

/// marks the beginning and the end of a curve
enum CurvePointType {
  begin,
  end,
  unknown;

  factory CurvePointType.from(String value) {
    return values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => CurvePointType.unknown,
    );
  }
}

/// Type of curve. Is provided only if type is [CurvePointType.begin]
enum CurveType {
  /// begins on the line and ends on the line or a station or a halt
  curve,

  /// begins in a station
  stationExitCurve,

  /// begins at an halt
  curveAfterHalt,
  unknown;

  factory CurveType.from(String value) {
    return values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => CurveType.unknown,
    );
  }
}

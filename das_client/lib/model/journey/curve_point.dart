import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';

class CurvePoint extends BaseData {
  CurvePoint({
    required super.order,
    required super.kilometre,
    super.trackEquipment,
    this.curvePointType,
    this.curveType,
    this.comment,
  }) : super(type: Datatype.curvePoint);

  final CurvePointType? curvePointType;
  final CurveType? curveType;
  final String? comment;
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

/// Type of curve. Is provided only if curvePointType = 'begin'
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

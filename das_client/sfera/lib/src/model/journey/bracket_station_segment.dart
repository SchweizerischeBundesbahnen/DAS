import 'package:sfera/src/model/journey/segment.dart';

class const BracketStationSegment({
  required final String mainStationAbbreviation,
  required super.startOrder,
  required super.endOrder,
}) extends Segment {
  @override
  String toString() {
    return 'BracketStationSegment{mainStationAbbreviation: $mainStationAbbreviation, startOrder: $startOrder, endOrder: $endOrder}';
  }
}

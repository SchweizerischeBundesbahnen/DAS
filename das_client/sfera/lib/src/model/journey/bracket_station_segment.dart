import 'package:sfera/src/model/journey/segment.dart';

class BracketStationSegment extends Segment {
  const BracketStationSegment({
    required this.mainStationAbbreviation,
    required final int startOrder,
    required final int endOrder,
  }) : super(startOrder: startOrder, endOrder: endOrder);

  final String mainStationAbbreviation;

  @override
  String toString() {
    return 'BracketStationSegment{mainStationAbbreviation: $mainStationAbbreviation, startOrder: $startOrder, endOrder: $endOrder}';
  }
}

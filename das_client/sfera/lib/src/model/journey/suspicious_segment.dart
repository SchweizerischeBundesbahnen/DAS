import 'package:sfera/src/model/journey/segment.dart';

/// Represents a suspicious segment profile referenced in the journey profile.
///
/// A segment is marked suspicious when problems occur, typically because of
/// incomplete or wrong route table data (the RADN document).
class SuspiciousSegment extends Segment {
  const SuspiciousSegment({
    super.startOrder,
    super.endOrder,
  });

  @override
  String toString() {
    return 'SuspiciousSegment{startOrder: $startOrder, endOrder: $endOrder}';
  }
}

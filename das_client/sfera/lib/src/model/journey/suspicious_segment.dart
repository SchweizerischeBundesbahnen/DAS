import 'package:sfera/src/model/journey/segment.dart';

/// Represents a suspicious segment profile referenced in the journey profile.
///
/// A segment is marked suspicious when problems occur, typically because of
/// incomplete or wrong route table data (the RADN document).
/// This segment stretches over the entire segment profile.
class SuspiciousSegment extends Segment {
  const SuspiciousSegment({
    required this.spId,
    super.startOrder,
    super.endOrder,
  });

  final String spId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuspiciousSegment &&
          runtimeType == other.runtimeType &&
          spId == other.spId &&
          startOrder == other.startOrder &&
          endOrder == other.endOrder;

  @override
  int get hashCode => Object.hash(spId, startOrder, endOrder);

  @override
  String toString() {
    return 'SuspiciousSegment{spId: $spId, startOrder: $startOrder, endOrder: $endOrder}';
  }
}

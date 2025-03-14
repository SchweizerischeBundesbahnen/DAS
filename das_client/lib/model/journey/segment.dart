import 'package:das_client/util/comparators.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
abstract class Segment implements Comparable {
  const Segment({
    this.startOrder,
    this.endOrder,
  });

  /// Start order of segment. Nullable as it can start in a journey segment that is not part of the train journey.
  final int? startOrder;

  /// End order of segment. Nullable as it can end in a journey segment that is not part of the train journey.
  final int? endOrder;

  /// checks if the given order is part of this segment.
  bool appliesToOrder(int order) {
    if (startOrder == null && endOrder == null) {
      return true; // applies for whole journey
    } else if (startOrder != null && endOrder != null) {
      return startOrder! <= order && order <= endOrder!;
    } else if (startOrder != null) {
      return startOrder! <= order;
    } else {
      return order <= endOrder!;
    }
  }

  @override
  int compareTo(other) {
    if (other is! Segment) return -1;

    final startEnd = (start: startOrder, end: endOrder);
    final otherStartEnd = (start: other.startOrder, end: other.endOrder);
    return StartEndIntComparator.compare(startEnd, otherStartEnd);
  }

  @override
  String toString() {
    return 'Segment(startOrder: $startOrder, endOrder: $endOrder)';
  }
}

// extensions

extension SegmentsExtension<T extends Segment> on Iterable<T> {
  Iterable<T> appliesToOrder(int order) => where((segment) => segment.appliesToOrder(order));

  Iterable<T> appliesToOrderRange(int start, int end) =>
      where((segment) => segment.appliesToOrder(start) && segment.appliesToOrder(end));
}

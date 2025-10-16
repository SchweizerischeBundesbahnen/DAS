import 'package:collection/collection.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class GroupedJourneyPoint extends JourneyPoint {
  const GroupedJourneyPoint({
    required super.type,
    required super.order,
    required super.kilometre,
    required this.groupedElements,
  });

  final List<JourneyPoint> groupedElements;

  @override
  String toString() {
    return 'GroupedJourneyPoint(order: $order, kilometre: $kilometre, groupedElements: $groupedElements)';
  }

  @override
  OrderPriority get orderPriority => OrderPriority.group;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaliseLevelCrossingGroup &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre) &&
          ListEquality().equals(groupedElements, other.groupedElements);

  @override
  int get hashCode => type.hashCode ^ order.hashCode ^ Object.hashAll(kilometre) ^ Object.hashAll(groupedElements);
}

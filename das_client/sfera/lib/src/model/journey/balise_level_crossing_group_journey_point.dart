import 'package:collection/collection.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class BaliseLevelCrossingGroupJourneyPoint extends JourneyPoint {
  const BaliseLevelCrossingGroupJourneyPoint({
    required super.order,
    required super.kilometre,
    required this.groupedElements,
  }) : super(type: Datatype.baliseLevelCrossingGroup);

  final List<BaseData> groupedElements;

  @override
  String toString() {
    return 'BaliseLevelCrossingGroup(order: $order, kilometre: $kilometre, groupedElements: $groupedElements)';
  }

  @override
  OrderPriority get orderPriority => OrderPriority.group;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaliseLevelCrossingGroupJourneyPoint &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre) &&
          ListEquality().equals(groupedElements, other.groupedElements);

  @override
  int get hashCode => order.hashCode ^ Object.hashAll(kilometre) ^ Object.hashAll(groupedElements);
}

import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class BaliseLevelCrossingGroup extends GroupedJourneyPoint {
  const BaliseLevelCrossingGroup({
    required super.order,
    required super.kilometre,
    required super.groupedElements,
  }) : super(type: Datatype.baliseLevelCrossingGroup);

  @override
  String toString() {
    return 'BaliseLevelCrossingGroup{order: $order, kilometre: $kilometre, groupedElements: $groupedElements}';
  }

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

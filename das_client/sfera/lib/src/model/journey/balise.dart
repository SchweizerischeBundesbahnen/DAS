import 'package:collection/collection.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class Balise extends JourneyPoint {
  const Balise({required super.order, required super.kilometre, required this.amountLevelCrossings, this.identifier})
    : super(dataType: .balise);

  final int amountLevelCrossings;
  final String? identifier;

  @override
  OrderPriority get orderPriority => .balise;

  @override
  String toString() {
    return 'Balise{order: $order, kilometre: $kilometre, amountLevelCrossings: $amountLevelCrossings, identifier: $identifier}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Balise &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          amountLevelCrossings == other.amountLevelCrossings &&
          const ListEquality().equals(kilometre, other.kilometre) &&
          identifier == other.identifier;

  @override
  int get hashCode => Object.hash(dataType, order, Object.hashAll(kilometre), amountLevelCrossings, identifier);
}

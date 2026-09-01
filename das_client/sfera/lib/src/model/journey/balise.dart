import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:sfera/component.dart';

class const Balise({
  required super.order,
  required super.kilometre,
  required final int amountLevelCrossings,
  final String? identifier,
}) extends JourneyPoint {
  this : super(dataType: .balise);

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

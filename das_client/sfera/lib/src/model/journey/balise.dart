import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class Balise extends JourneyPoint {
  const Balise({
    required super.order,
    required super.kilometre,
    required this.amountLevelCrossings,
  }) : super(type: Datatype.balise);

  final int amountLevelCrossings;

  @override
  String toString() =>
      'Balise('
      'order: $order'
      ', kilometre: $kilometre'
      ', amountLevelCrossings: $amountLevelCrossings'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Balise &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          amountLevelCrossings == other.amountLevelCrossings &&
          ListEquality().equals(kilometre, other.kilometre);

  @override
  int get hashCode => order.hashCode ^ Object.hashAll(kilometre) ^ amountLevelCrossings.hashCode;
}

import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class TramArea extends JourneyPoint {
  const TramArea({
    required super.order,
    required super.kilometre,
    required this.endKilometre,
    required this.amountTramSignals,
  }) : super(type: Datatype.tramArea);

  final double endKilometre;
  final int amountTramSignals;

  @override
  String toString() =>
      'TramArea('
      'order: $order'
      ', kilometre: $kilometre'
      ', endKilometre: $endKilometre'
      ', amountTramSignals: $amountTramSignals'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TramArea &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre) &&
          endKilometre == other.endKilometre &&
          amountTramSignals == other.amountTramSignals;

  @override
  int get hashCode =>
      type.hashCode ^ order.hashCode ^ Object.hashAll(kilometre) ^ endKilometre.hashCode ^ amountTramSignals.hashCode;
}

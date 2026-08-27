import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class const TramArea({
  required super.order,
  required super.kilometre,
  required final double endKilometre,
  required final int amountTramSignals,
}) extends JourneyPoint {
  this : super(dataType: .tramArea);

  @override
  String toString() {
    return 'TramArea{order: $order, kilometre: $kilometre, endKilometre: $endKilometre, amountTramSignals: $amountTramSignals}';
  }

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
      dataType.hashCode ^
      order.hashCode ^
      Object.hashAll(kilometre) ^
      endKilometre.hashCode ^
      amountTramSignals.hashCode;
}

import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class Whistle extends JourneyPoint {
  const Whistle({required super.order, required super.kilometre}) : super(type: Datatype.whistle);

  @override
  String toString() =>
      'Whistle('
      'order: $order'
      ', kilometre: $kilometre'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Whistle &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre);

  @override
  int get hashCode => order.hashCode ^ Object.hashAll(kilometre);
}

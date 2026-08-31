import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class const Whistle({required super.order, required super.kilometre}) extends JourneyPoint {
  this : super(dataType: .whistle);

  @override
  String toString() {
    return 'Whistle{order: $order, kilometre: $kilometre}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Whistle &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre);

  @override
  int get hashCode => dataType.hashCode ^ order.hashCode ^ Object.hashAll(kilometre);
}

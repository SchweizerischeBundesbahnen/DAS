import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class const SpeedChange({
  required super.order,
  required super.kilometre,
  final String? text,
  super.lastModificationDate,
  super.lastModificationType,
}) extends JourneyPoint {
  this : super(dataType: .speedChange);

  @override
  String toString() {
    return 'SpeedChange{order: $order, kilometre: $kilometre, text: $text}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeedChange &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre) &&
          text == other.text;

  @override
  int get hashCode => dataType.hashCode ^ order.hashCode ^ Object.hashAll(kilometre) ^ text.hashCode;
}

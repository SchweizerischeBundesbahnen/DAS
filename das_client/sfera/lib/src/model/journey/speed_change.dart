import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class SpeedChange extends JourneyPoint {
  const SpeedChange({
    required super.order,
    required super.kilometre,
    this.text,
    super.lastModificationDate,
    super.lastModificationType,
  }) : super(dataType: .speedChange);

  final String? text;

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

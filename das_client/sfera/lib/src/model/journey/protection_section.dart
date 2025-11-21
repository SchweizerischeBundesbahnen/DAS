import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class ProtectionSection extends JourneyPoint {
  const ProtectionSection({
    required this.isOptional,
    required this.isLong,
    required super.order,
    required super.kilometre,
  }) : super(type: Datatype.protectionSection);

  final bool isOptional;
  final bool isLong;

  @override
  String toString() {
    return 'ProtectionSection{order: $order, kilometre: $kilometre, isOptional: $isOptional, isLong: $isLong}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtectionSection &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre) &&
          isOptional == other.isOptional &&
          isLong == other.isLong;

  @override
  int get hashCode =>
      type.hashCode ^ order.hashCode ^ Object.hashAll(kilometre) ^ isOptional.hashCode ^ isLong.hashCode;
}

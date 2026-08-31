import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class const ProtectionSection({
  required final bool isOptional,
  required final bool isLong,
  required super.order,
  required super.kilometre,
  super.lastModificationDate,
  super.lastModificationType,
}) extends JourneyPoint {
  this : super(dataType: .protectionSection);

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
      dataType.hashCode ^ order.hashCode ^ Object.hashAll(kilometre) ^ isOptional.hashCode ^ isLong.hashCode;
}

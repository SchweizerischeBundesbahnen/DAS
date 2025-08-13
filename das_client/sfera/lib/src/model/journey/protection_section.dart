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
    return 'ProtectionSection(order: $order, kilometre: $kilometre, isOptional: $isOptional, isLong: $isLong)';
  }
}

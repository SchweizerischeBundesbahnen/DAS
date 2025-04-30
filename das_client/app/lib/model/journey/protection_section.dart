import 'package:app/model/journey/base_data.dart';
import 'package:app/model/journey/datatype.dart';

class ProtectionSection extends BaseData {
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

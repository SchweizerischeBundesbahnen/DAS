import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class UncodedOperationalIndication extends BaseData {
  const UncodedOperationalIndication({
    required super.order,
    required this.text,
  }) : super(type: Datatype.uncodedOperationalIndication, kilometre: const []);

  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UncodedOperationalIndication &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          order == other.order;

  @override
  int get hashCode => text.hashCode ^ order.hashCode;

  @override
  OrderPriority get orderPriority => OrderPriority.uncodedOperationalIndication;
}

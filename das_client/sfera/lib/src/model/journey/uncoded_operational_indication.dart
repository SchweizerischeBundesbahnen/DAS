import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class UncodedOperationalIndication extends BaseData {
  const UncodedOperationalIndication({
    required super.order,
    required this.text,
  }) : super(type: Datatype.uncodedOperationalIndication, kilometre: const []);

  final String text;

  @override
  OrderPriority get orderPriority => OrderPriority.uncodedOperationalIndication;
}

import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class CABSignaling extends JourneyPoint {
  const CABSignaling({
    required super.order,
    required super.kilometre,
    this.isStart = false,
  }) : super(type: Datatype.cabSignaling);

  final bool isStart;

  bool get isEnd => !isStart;

  @override
  OrderPriority get orderPriority => isStart ? OrderPriority.cabSignalingStart : OrderPriority.cabSignalingEnd;

  @override
  String toString() {
    return 'CABSignaling(order: $order, kilometre: $kilometre, isStart: $isStart)';
  }
}

import 'package:app/model/journey/base_data.dart';
import 'package:app/model/journey/datatype.dart';
import 'package:app/model/journey/order_priority.dart';

class CABSignaling extends BaseData {
  const CABSignaling({
    required super.order,
    required super.kilometre,
    super.speedData,
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

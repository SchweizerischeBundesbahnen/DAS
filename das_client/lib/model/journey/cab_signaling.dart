import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';

class CABSignaling extends BaseData {
  const CABSignaling({
    required super.order,
    required super.kilometre,
    this.isStart = false,
  }) : super(type: Datatype.cabSignaling);

  final bool isStart;

  bool get isEnd => !isStart;

  @override
  int get orderPriority => isStart ? -1 : 1;

  @override
  String toString() {
    return 'CABSignaling(order: $order, kilometre: $kilometre, isStart: $isStart)';
  }
}
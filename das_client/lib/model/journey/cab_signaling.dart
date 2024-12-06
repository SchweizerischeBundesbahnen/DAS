import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';

class CABSignaling extends BaseData {
  CABSignaling({
    required super.order,
    required super.kilometre,
    this.isStart = false,
  }) : super(type: Datatype.cabSignaling);

  final bool isStart;

  @override
  int compareTo(other) {
    final comparison = super.compareTo(other);
    if (comparison != 0) {
      return comparison;
    }

    return isStart ? -1 : 1;
  }

  @override
  String toString() {
    return 'CABSignaling(order: $order, kilometre: $kilometre, isStart: $isStart)';
  }
}
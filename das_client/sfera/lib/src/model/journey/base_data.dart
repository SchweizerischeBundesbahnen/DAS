import 'package:meta/meta.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

@sealed
@immutable
abstract class BaseData implements Comparable {
  const BaseData({
    required this.dataType,
    required this.order,
  });

  final Datatype dataType;
  final int order;

  @override
  int compareTo(other) {
    if (other is! BaseData) return -1;
    final orderCompare = order.compareTo(other.order);
    if (orderCompare == 0) {
      return orderPriority.index.compareTo(other.orderPriority.index);
    }
    return orderCompare;
  }

  /// Used for comparing if [order] is equal.
  /// If [orderPriority] is smaller, this is ordered before other, a bigger value is ordered after other.
  OrderPriority get orderPriority => .baseData;
}

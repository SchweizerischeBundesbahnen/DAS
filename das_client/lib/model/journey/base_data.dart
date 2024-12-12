import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/speed_data.dart';

abstract class BaseData implements Comparable {
  BaseData({
    required this.type,
    required this.order,
    required this.kilometre,
    this.speedData,
  });

  final Datatype type;
  final int order;
  final List<double> kilometre;
  final SpeedData? speedData;

  @override
  int compareTo(other) {
    if (other is! BaseData) return -1;
    final orderCompare = order.compareTo(other.order);
    if (orderCompare == 0) {
      return orderPriority.compareTo(other.orderPriority);
    }
    return orderCompare;
  }

  /// Used for comparing if [order] is equal.
  /// If [orderPriority] is smaller, this is ordered before other, a bigger value is ordered after other.
  int get orderPriority => 0;
}

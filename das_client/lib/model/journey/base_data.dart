import 'package:das_client/model/journey/base_data_extension.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/order_priority.dart';
import 'package:das_client/model/journey/speed_data.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
abstract class BaseData implements Comparable {
  const BaseData({
    required this.type,
    required this.order,
    required this.kilometre,
    this.speedData,
    this.localSpeedData,
  });

  final Datatype type;
  final int order;
  final List<double> kilometre;
  final SpeedData? speedData;
  final SpeedData? localSpeedData;

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
  OrderPriority get orderPriority => OrderPriority.baseData;

  /// Used to indicate that this element can be grouped together
  /// [canGroup] and [canGroupWith] needs to be overridden for elements to be able to be grouped
  /// Grouping is done in [BaseDataExtension]
  bool get canGroup => false;

  /// Used to check if the current element is allowed to be grouped with the other element
  /// Only gets checked if [canGroup] is already true
  /// Grouping is done in [BaseDataExtension]
  bool canGroupWith(BaseData other) {
    return false;
  }
}

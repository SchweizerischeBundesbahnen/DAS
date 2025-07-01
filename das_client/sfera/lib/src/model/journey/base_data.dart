import 'package:meta/meta.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

@sealed
@immutable
abstract class BaseData implements Comparable {
  const BaseData({
    required this.type,
    required this.order,
    required this.kilometre,
    this.speeds,
    this.localSpeeds,
  });

  final Datatype type;
  final int order;
  final List<double> kilometre;
  final List<TrainSeriesSpeed>? speeds;
  final List<TrainSeriesSpeed>? localSpeeds;

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

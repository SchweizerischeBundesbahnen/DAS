import 'package:das_client/model/journey/datatype.dart';

abstract class BaseData implements Comparable {
  BaseData({
    required this.type,
    required this.order,
    required this.kilometre,
  });

  final Datatype type;
  final int order;
  final List<double> kilometre;

  @override
  int compareTo(other) {
    if(other is! BaseData) return -1;
    return order.compareTo(other.order);
  }
}

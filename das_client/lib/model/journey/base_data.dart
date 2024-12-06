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
    if(other is! BaseData) return -1;
    return order.compareTo(other.order);
  }
}

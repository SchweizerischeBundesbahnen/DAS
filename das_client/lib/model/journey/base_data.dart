import 'package:das_client/model/journey/datatype.dart';

abstract class BaseData {
  BaseData({required this.type, required this.order, required this.kilometre});

  final Datatype type;
  final int order;
  final List<double> kilometre;
}

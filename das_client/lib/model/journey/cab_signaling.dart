import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';

class CABSignaling extends BaseData {
  CABSignaling({
    required super.order,
    required super.kilometre,
    this.isStart = false,
  }) : super(type: Datatype.cabSignaling);

  final bool isStart;
}
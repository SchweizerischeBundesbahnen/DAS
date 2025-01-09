import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';

class Whistle extends BaseData {
  Whistle({required super.order, required super.kilometre, super.speedData}) : super(type: Datatype.whistle);
}

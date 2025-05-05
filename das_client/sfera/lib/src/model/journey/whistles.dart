import 'package:sfera/src/model/journey/base_data.dart';
import 'package:sfera/src/model/journey/datatype.dart';

class Whistle extends BaseData {
  const Whistle({required super.order, required super.kilometre, super.speedData}) : super(type: Datatype.whistle);
}

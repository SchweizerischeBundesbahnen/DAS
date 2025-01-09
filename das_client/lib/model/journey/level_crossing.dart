import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';

class LevelCrossing extends BaseData {
  LevelCrossing({required super.order, required super.kilometre, super.speedData})
      : super(type: Datatype.levelCrossing);
}

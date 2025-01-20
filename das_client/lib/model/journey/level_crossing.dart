import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';

class LevelCrossing extends BaseData {
  const LevelCrossing({
    required super.order,
    required super.kilometre,
    super.speedData,
  }) : super(type: Datatype.levelCrossing);

  @override
  bool get canGroup => true;

  @override
  bool canGroupWith(BaseData other) {
    return [Datatype.balise, Datatype.levelCrossing].contains(other.type);
  }
}

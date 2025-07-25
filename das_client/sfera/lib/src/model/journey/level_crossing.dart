import 'package:sfera/src/model/journey/base_data.dart';
import 'package:sfera/src/model/journey/datatype.dart';

class LevelCrossing extends BaseData {
  const LevelCrossing({
    required super.order,
    required super.kilometre,
  }) : super(type: Datatype.levelCrossing);

  @override
  bool get canGroup => true;

  @override
  bool canGroupWith(BaseData other) {
    return [Datatype.balise, Datatype.levelCrossing].contains(other.type);
  }
}

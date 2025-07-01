import 'package:sfera/src/model/journey/base_data.dart';
import 'package:sfera/src/model/journey/datatype.dart';
import 'package:sfera/src/model/journey/level_crossing.dart';

class Balise extends BaseData {
  const Balise({
    required super.order,
    required super.kilometre,
    required this.amountLevelCrossings,
    super.speeds,
  }) : super(type: Datatype.balise);

  final int amountLevelCrossings;

  @override
  bool get canGroup => true;

  @override
  bool canGroupWith(BaseData other) {
    if (other is LevelCrossing) {
      return true;
    } else if (other is Balise) {
      return amountLevelCrossings == 1 && other.amountLevelCrossings == 1;
    } else {
      return false;
    }
  }
}

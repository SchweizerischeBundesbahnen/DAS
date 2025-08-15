import 'package:sfera/component.dart';

class LevelCrossing extends JourneyPoint {
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

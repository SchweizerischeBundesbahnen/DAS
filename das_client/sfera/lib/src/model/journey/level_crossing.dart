import 'package:collection/collection.dart';
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

  @override
  String toString() =>
      'LevelCrossing('
      'order: $order'
      ', kilometre: $kilometre'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelCrossing &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre);

  @override
  int get hashCode => order.hashCode ^ Object.hashAll(kilometre);
}

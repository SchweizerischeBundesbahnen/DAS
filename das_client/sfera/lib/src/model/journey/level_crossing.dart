import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class LevelCrossing extends JourneyPoint {
  const LevelCrossing({
    required super.order,
    required super.kilometre,
    int? originalOrder,
  }) : _originalOrder = originalOrder ?? order,
       super(type: Datatype.levelCrossing);

  final int _originalOrder;

  @override
  String toString() {
    return 'LevelCrossing{order: $order, kilometre: $kilometre, originalOrder: $_originalOrder}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelCrossing &&
          runtimeType == other.runtimeType &&
          _originalOrder == other._originalOrder &&
          ListEquality().equals(kilometre, other.kilometre);

  @override
  int get hashCode => type.hashCode ^ _originalOrder.hashCode ^ Object.hashAll(kilometre);

  LevelCrossing copyWith({int? order}) {
    return LevelCrossing(
      order: order ?? this.order,
      kilometre: kilometre,
      originalOrder: _originalOrder,
    );
  }
}

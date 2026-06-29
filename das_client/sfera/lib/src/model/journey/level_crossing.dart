import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class LevelCrossing extends JourneyPoint {
  const LevelCrossing({
    required super.order,
    required super.kilometre,
    int? originalOrder,
    this.identifier,
  }) : _originalOrder = originalOrder ?? order,
       super(dataType: .levelCrossing);

  final int _originalOrder;
  final String? identifier;

  @override
  String toString() {
    return 'LevelCrossing{order: $order, kilometre: $kilometre, originalOrder: $_originalOrder, identifier: $identifier}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelCrossing &&
          runtimeType == other.runtimeType &&
          dataType == other.dataType &&
          _originalOrder == other._originalOrder &&
          identifier == other.identifier &&
          ListEquality().equals(kilometre, other.kilometre);

  @override
  int get hashCode => Object.hash(dataType, _originalOrder, Object.hashAll(kilometre), identifier);

  LevelCrossing copyWith({int? order}) {
    return LevelCrossing(
      order: order ?? this.order,
      kilometre: kilometre,
      originalOrder: _originalOrder,
      identifier: identifier,
    );
  }
}

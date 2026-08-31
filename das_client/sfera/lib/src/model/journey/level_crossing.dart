import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class const LevelCrossing({
  required super.order,
  required super.kilometre,
  final String? identifier,
  int? originalOrder,
}) extends JourneyPoint {
  this : _originalOrder = originalOrder ?? order, super(dataType: .levelCrossing);

  final int _originalOrder;

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

  @override
  int compareTo(other) {
    if (other is LevelCrossing) {
      final orderCompare = order.compareTo(other.order);
      if (orderCompare == 0) {
        return _originalOrder.compareTo(other._originalOrder);
      }
    }
    return super.compareTo(other);
  }
}

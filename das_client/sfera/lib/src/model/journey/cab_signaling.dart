import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:sfera/component.dart';

class const CABSignaling({
  required super.order,
  required super.kilometre,
  final bool isStart = false,
}) extends JourneyPoint {
  this : super(dataType: .cabSignaling);

  bool get isEnd => !isStart;

  @override
  OrderPriority get orderPriority => isStart ? .cabSignalingStart : .cabSignalingEnd;

  @override
  String toString() {
    return 'CABSignaling{order: $order, kilometre: $kilometre, isStart: $isStart}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CABSignaling &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre) &&
          isStart == other.isStart;

  @override
  int get hashCode => dataType.hashCode ^ order.hashCode ^ Object.hashAll(kilometre) ^ isStart.hashCode;
}

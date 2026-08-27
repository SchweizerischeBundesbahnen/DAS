import 'package:core_data/component.dart';

class const ShuntingMovement({
  required super.order,
  final bool isStart = true,
}) extends JourneyAnnotation {
  this : super(dataType: .shuntingMovement);

  bool get isEnd => !isStart;

  @override
  OrderPriority get orderPriority => isStart ? .shuntingMovementStart : .shuntingMovementEnd;

  @override
  String toString() {
    return 'ShuntingMovement{order: $order, isStart: $isStart}';
  }
}

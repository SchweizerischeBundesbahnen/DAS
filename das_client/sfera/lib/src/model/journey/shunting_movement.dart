import 'package:core_data/component.dart';

class ShuntingMovement extends JourneyAnnotation {
  const ShuntingMovement({
    required super.order,
    this.isStart = true,
  }) : super(dataType: .shuntingMovement);

  final bool isStart;

  bool get isEnd => !isStart;

  @override
  OrderPriority get orderPriority => isStart ? .shuntingMovementStart : .shuntingMovementEnd;

  @override
  String toString() {
    return 'ShuntingMovement{order: $order, isStart: $isStart}';
  }
}

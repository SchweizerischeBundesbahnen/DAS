import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class ShuntingMovement extends JourneyAnnotation {
  const ShuntingMovement({
    required super.order,
    this.isStart = true,
  }) : super(type: Datatype.shuntingMovement);

  final bool isStart;

  bool get isEnd => !isStart;

  @override
  OrderPriority get orderPriority => isStart ? OrderPriority.shuntingMovementStart : OrderPriority.shuntingMovementEnd;
}

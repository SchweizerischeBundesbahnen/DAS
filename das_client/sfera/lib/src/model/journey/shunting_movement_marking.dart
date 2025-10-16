import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class ShuntingMovementMarking extends JourneyAnnotation {
  const ShuntingMovementMarking({
    required super.order,
    this.isStart = true,
  }) : super(type: Datatype.shuntingMovementMarking);

  final bool isStart;

  bool get isEnd => !isStart;

  @override
  OrderPriority get orderPriority => isStart ? OrderPriority.shuntingMovementStart : OrderPriority.shuntingMovementEnd;
}

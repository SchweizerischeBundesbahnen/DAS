import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class TrainDriverTurnover extends JourneyAnnotation {
  const TrainDriverTurnover({
    required super.order,
    required this.isStart,
  }) : super(dataType: Datatype.trainDriverTurnover);

  final bool isStart;

  @override
  OrderPriority get orderPriority =>
      isStart ? OrderPriority.trainDriverTurnoverStart : OrderPriority.trainDriverTurnoverEnd;
}

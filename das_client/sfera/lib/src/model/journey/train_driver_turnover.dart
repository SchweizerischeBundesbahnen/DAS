import 'package:core_data/component.dart';

class const TrainDriverTurnover({
  required super.order,
  required final bool isStart,
}) extends JourneyAnnotation {
  this : super(dataType: .trainDriverTurnover);

  @override
  OrderPriority get orderPriority => isStart ? .trainDriverTurnoverStart : .trainDriverTurnoverEnd;
}

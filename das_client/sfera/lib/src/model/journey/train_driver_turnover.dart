import 'package:core_data/component.dart';

class TrainDriverTurnover extends JourneyAnnotation {
  const TrainDriverTurnover({
    required super.order,
    required this.isStart,
  }) : super(dataType: .trainDriverTurnover);

  final bool isStart;

  @override
  OrderPriority get orderPriority => isStart ? .trainDriverTurnoverStart : .trainDriverTurnoverEnd;
}

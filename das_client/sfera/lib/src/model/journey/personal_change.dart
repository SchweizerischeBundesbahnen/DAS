import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class PersonalChange extends JourneyAnnotation {
  const PersonalChange({
    required super.order,
    required this.isStart,
  }) : super(dataType: Datatype.personalChange);

  final bool isStart;

  @override
  OrderPriority get orderPriority => isStart ? OrderPriority.personalChangeStart : OrderPriority.personalChangeEnd;
}

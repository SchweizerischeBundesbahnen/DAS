import 'package:sfera/component.dart';

class BaliseLevelCrossingGroup extends JourneyPoint {
  const BaliseLevelCrossingGroup({
    required super.order,
    required super.kilometre,
    required this.groupedElements,
  }) : super(type: Datatype.baliseLevelCrossingGroup);

  final List<BaseData> groupedElements;
}

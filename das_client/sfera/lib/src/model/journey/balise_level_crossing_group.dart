import 'package:sfera/src/model/journey/base_data.dart';
import 'package:sfera/src/model/journey/datatype.dart';

class BaliseLevelCrossingGroup extends BaseData {
  const BaliseLevelCrossingGroup({
    required super.order,
    required super.kilometre,
    required this.groupedElements,
    super.speeds,
  }) : super(type: Datatype.baliseLevelCrossingGroup);

  final List<BaseData> groupedElements;
}

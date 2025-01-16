import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';

class BaliseLevelCrossingGroup extends BaseData {
  const BaliseLevelCrossingGroup({
    required super.order,
    required super.kilometre,
    required this.groupedElements,
    super.speedData,
  }) : super(type: Datatype.baliseLevelCrossingGroup);

  final List<BaseData> groupedElements;
}

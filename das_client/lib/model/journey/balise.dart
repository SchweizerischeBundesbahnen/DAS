import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';

class Balise extends BaseData {
  Balise({
    required super.order,
    required super.kilometre,
    required this.amountLevelCrossings,
    super.speedData,
  }) : super(type: Datatype.balise);

  final int amountLevelCrossings;
}

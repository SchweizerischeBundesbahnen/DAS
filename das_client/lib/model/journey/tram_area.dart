import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';

class TramArea extends BaseData {
  const TramArea({
    required super.order,
    required super.kilometre,
    required this.endKilometre,
    required this.amountTramSignals,
    super.speedData,
  }) : super(type: Datatype.tramArea);

  final double endKilometre;
  final int amountTramSignals;
}

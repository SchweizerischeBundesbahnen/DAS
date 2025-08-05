import 'package:sfera/src/model/journey/base_data.dart';
import 'package:sfera/src/model/journey/datatype.dart';

class TramArea extends BaseData {
  const TramArea({
    required super.order,
    required super.kilometre,
    required this.endKilometre,
    required this.amountTramSignals,
  }) : super(type: Datatype.tramArea);

  final double endKilometre;
  final int amountTramSignals;
}

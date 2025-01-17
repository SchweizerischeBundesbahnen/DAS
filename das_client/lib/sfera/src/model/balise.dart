import 'package:das_client/sfera/src/model/sp_generic_point.dart';
import 'package:das_client/util/util.dart';

class Balise extends SpGenericPoint {
  static const String elementType = 'Balise';

  Balise({super.type = elementType, super.attributes, super.children, super.value});

  int get amountLevelCrossings => Util.tryParseInt(attributes['amountLevelCrossings']) ?? 1;
}

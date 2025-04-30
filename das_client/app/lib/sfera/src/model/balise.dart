import 'package:app/sfera/src/model/sp_generic_point.dart';
import 'package:app/util/util.dart';

class Balise extends SpGenericPoint {
  static const String elementType = 'Balise';

  Balise({super.type = elementType, super.attributes, super.children, super.value});

  int get amountLevelCrossings => Util.tryParseInt(attributes['amountLevelCrossings']) ?? 1;
}

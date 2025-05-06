import 'package:sfera/src/data/dto/sp_generic_point_dto.dart';
import 'package:app/util/util.dart';

class BaliseDto extends SpGenericPointDto {
  static const String elementType = 'Balise';

  BaliseDto({super.type = elementType, super.attributes, super.children, super.value});

  int get amountLevelCrossings => Util.tryParseInt(attributes['amountLevelCrossings']) ?? 1;
}

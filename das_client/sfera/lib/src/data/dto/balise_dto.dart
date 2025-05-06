import 'package:sfera/src/data/dto/sp_generic_point_dto.dart';
import 'package:sfera/src/data/parser/parse_utils.dart';

class BaliseDto extends SpGenericPointDto {
  static const String elementType = 'Balise';

  BaliseDto({super.type = elementType, super.attributes, super.children, super.value});

  int get amountLevelCrossings => ParseUtils.tryParseInt(attributes['amountLevelCrossings']) ?? 1;
}

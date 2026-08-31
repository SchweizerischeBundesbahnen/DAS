import 'package:sfera/src/data/dto/km_reference_dto.dart';
import 'package:sfera/src/data/dto/sp_generic_point_dto.dart';

class KilometreReferencePointDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SpGenericPointDto {
  static const String elementType = 'KilometreReferencePoint';

  KmReferenceDto get kmReference => children.whereType<KmReferenceDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<KmReferenceDto>() && super.validate();
  }
}

import 'package:sfera/src/data/dto/jp_context_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/km_ref_nsp_dto.dart';

class KilometreReferencePointNspDto extends JpContextInformationNspDto {
  static const String elementName = 'kilometreReferencePoint';

  KilometreReferencePointNspDto({
    super.type,
    super.attributes,
    super.children,
    super.value,
  });

  double get kmRef => children.whereType<KmRefNspDto>().first.kmRef;

  @override
  bool validate() => validateHasChildOfType<KmRefNspDto>() && super.validate();
}

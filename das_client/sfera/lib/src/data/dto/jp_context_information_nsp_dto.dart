import 'package:sfera/src/data/dto/jp_context_information_nsp_constraints_dto.dart';
import 'package:sfera/src/data/dto/nsp_dto.dart';

class JpContextInformationNspDto extends NspDto {
  static const String elementType = 'JP_ContextInformation_NSPs';

  JpContextInformationNspDto({super.type = elementType, super.attributes, super.children, super.value});

  JpContextInformationNspConstraintsDto get constraint =>
      children.whereType<JpContextInformationNspConstraintsDto>().first;

  @override
  bool validate() => validateHasChildOfType<JpContextInformationNspConstraintsDto>() && super.validate();
}

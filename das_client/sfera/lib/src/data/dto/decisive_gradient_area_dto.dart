import 'package:sfera/src/data/dto/enums/direction_of_application_on_sp_dto.dart';
import 'package:sfera/src/data/dto/enums/gradient_direction_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/sfera_segment_xml_element_dto.dart';

class DecisiveGradientAreaDto extends SferaSegmentXmlElementDto {
  static const String elementType = 'DecisiveGradientArea';

  DecisiveGradientAreaDto({super.type = elementType, super.attributes, super.children, super.value});

  double get gradientValue => double.parse(attributes['gradientValue']!);

  GradientDirectionTypeDto get gradientDirectionType =>
      XmlEnum.valueOf(GradientDirectionTypeDto.values, attributes['gradientDirection'])!;

  DirectionOfApplicationOnSPDto get directionOfApplicationOnSP =>
      XmlEnum.valueOf(DirectionOfApplicationOnSPDto.values, attributes['directionOfApplicationOnSP'])!;

  @override
  bool validate() =>
      super.validate() &&
      validateHasAttributeDouble('gradientValue') &&
      validateHasAttributeInRange('gradientDirection', XmlEnum.values(GradientDirectionTypeDto.values)) &&
      validateHasAttributeInRange('directionOfApplicationOnSP', XmlEnum.values(DirectionOfApplicationOnSPDto.values));
}

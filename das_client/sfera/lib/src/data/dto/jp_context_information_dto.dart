import 'package:sfera/src/data/dto/jp_context_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/operational_indication_nsp_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class JpContextInformationDto extends SferaXmlElementDto {
  static const String elementType = 'JP_ContextInformation';

  JpContextInformationDto({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<JpContextInformationNspDto> get contextInformationNsp => children.whereType<JpContextInformationNspDto>();

  Iterable<OperationalIndicationNspDto> get operationalIndications => children.whereType<OperationalIndicationNspDto>();
}

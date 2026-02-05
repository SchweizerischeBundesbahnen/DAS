import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/tms_data_dto.dart';

class GeneralJpInformationDto extends SferaXmlElementDto {
  static const String elementType = 'General_JP_Information';

  GeneralJpInformationDto({super.type = elementType, super.attributes, super.children, super.value});

  TmsDataNspDto? get tmsDataNsp => children.whereType<TmsDataNspDto>().firstOrNull;
}

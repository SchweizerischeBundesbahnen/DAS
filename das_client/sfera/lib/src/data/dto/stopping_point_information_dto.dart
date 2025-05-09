import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/stop_type_dto.dart';

class StoppingPointInformationDto extends SferaXmlElementDto {
  static const String elementType = 'StoppingPointInformation';

  StoppingPointInformationDto({super.type = elementType, super.attributes, super.children, super.value});

  StopTypeDto? get stopType => children.whereType<StopTypeDto>().firstOrNull;
}

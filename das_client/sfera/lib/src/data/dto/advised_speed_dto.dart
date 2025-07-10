import 'package:sfera/src/data/dto/advice_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class AdvisedSpeedDto extends SferaXmlElementDto {
  static const String elementType = 'AdvisedSpeed';

  AdvisedSpeedDto({super.type = elementType, super.attributes, super.children, super.value});

  AdviceTypeDto? get adviceType => XmlEnum.valueOf(AdviceTypeDto.values, attributes['adviceType']);
}

import 'package:sfera/src/data/dto/general_jp_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/operating_day_nsp.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class GeneralJpInformationDto extends SferaXmlElementDto {
  static const String elementType = 'General_JP_Information';

  GeneralJpInformationDto({super.type = elementType, super.attributes, super.children, super.value});

  OperatingDayNsp? get operatingDayNsp =>
      children.whereType<GeneralJpInformationNspDto>().map((it) => it.operatingDayNsp).nonNulls.firstOrNull;
}

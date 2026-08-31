import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class GraduatedSpeedInfoEntityDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  static const String elementType = 'entry';

  String? get nSpeed => attributes['nSpeed'];

  String? get roSpeed => attributes['roSpeed'];

  String? get adSpeed => attributes['adSpeed'];

  String? get sSpeed => attributes['sSpeed'];

  String? get text => attributes['text'];
}

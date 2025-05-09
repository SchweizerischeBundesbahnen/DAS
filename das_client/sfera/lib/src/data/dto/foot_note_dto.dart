import 'package:sfera/src/data/dto/enums/foot_note_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/text_dto.dart';

class SferaFootNoteDto extends SferaXmlElementDto {
  static const String elementType = 'footNote';

  SferaFootNoteDto({super.type = elementType, super.attributes, super.children, super.value});

  String get text => children.whereType<TextDto>().first.xmlValue;

  String? get identifier => attributes['identifier'];

  String? get trainSeries => childrenWithType('trainSeries').firstOrNull?.value;

  SferaFootNoteTypeDto? get footNoteType => XmlEnum.valueOf(SferaFootNoteTypeDto.values, attributes['type']);

  String? get refText => attributes['refText'];

  @override
  bool validate() {
    return validateHasChild('text') && super.validate();
  }
}

import 'package:sfera/src/data/dto/foot_note_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class LineFootNotesDto extends SferaXmlElementDto {
  static const String elementType = 'lineFootNotes';

  LineFootNotesDto({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<SferaFootNoteDto> get footNotes => children.whereType<SferaFootNoteDto>();
}

import 'package:sfera/src/data/dto/graduated_speed_info_entry_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class GraduatedSpeedInfoEntriesDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  static const String elementType = 'entries';

  Iterable<GraduatedSpeedInfoEntryDto> get entries => children.whereType<GraduatedSpeedInfoEntryDto>();
}

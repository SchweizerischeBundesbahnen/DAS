import 'package:sfera/src/data/dto/graduated_speed_info_entries_dto.dart';
import 'package:sfera/src/data/dto/graduated_speed_info_entry_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class GraduatedSpeedInfoDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  static const String elementType = 'graduatedSpeedInfo';

  Iterable<GraduatedSpeedInfoEntryDto> get entities => children.whereType<GraduatedSpeedInfoEntriesDto>().first.entries;

  @override
  bool validate() {
    return validateHasChildOfType<GraduatedSpeedInfoEntriesDto>() && super.validate();
  }
}

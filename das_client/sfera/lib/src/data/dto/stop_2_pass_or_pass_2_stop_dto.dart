import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/stop_pass_change_dto.dart';

class Stop2PassOrPass2StopDto extends SferaXmlElementDto {
  static const String elementType = 'stop2PassOrPass2Stop';

  Stop2PassOrPass2StopDto({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<StopPassChangeDto> get changes => children.whereType<StopPassChangeDto>();

  @override
  bool validate() {
    return super.validateHasChildOfType<StopPassChangeDto>() && super.validate();
  }
}

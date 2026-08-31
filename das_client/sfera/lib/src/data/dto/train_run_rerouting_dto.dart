import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/train_run_rerouting_change_dto.dart';

class TrainRunReroutingDto({super.type = elementType, super.attributes, super.children, super.value})
    extends SferaXmlElementDto {
  static const String elementType = 'trainRunRerouting';

  Iterable<TrainRunReroutingChangeDto> get changes => children.whereType<TrainRunReroutingChangeDto>();

  @override
  bool validate() {
    return super.validateHasChildOfType<TrainRunReroutingChangeDto>() && super.validate();
  }
}

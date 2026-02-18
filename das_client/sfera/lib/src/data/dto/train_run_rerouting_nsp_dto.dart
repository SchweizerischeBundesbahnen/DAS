import 'package:sfera/src/data/dto/general_jp_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/xml_train_run_rerouting_dto.dart';

class TrainRunReroutingNspDto extends GeneralJpInformationNspDto {
  static const String groupNameValue = 'trainRunRerouting';

  TrainRunReroutingNspDto({super.type, super.attributes, super.children, super.value});

  XmlTrainRunReroutingDto get xmlTrainRunRerouting => children.whereType<XmlTrainRunReroutingDto>().first;

  @override
  bool validate() {
    return super.validateHasChildOfType<XmlTrainRunReroutingDto>() && super.validate();
  }
}

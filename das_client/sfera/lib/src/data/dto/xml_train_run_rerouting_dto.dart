import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/nsp_xml_element_dto.dart';
import 'package:sfera/src/data/dto/train_run_rerouting_dto.dart';

class XmlTrainRunReroutingDto extends NetworkSpecificParameterDto with NspXmlElementDto<TrainRunReroutingDto> {
  static const String elementName = 'xmlTrainRunRerouting';

  XmlTrainRunReroutingDto({super.attributes, super.children, super.value});
}

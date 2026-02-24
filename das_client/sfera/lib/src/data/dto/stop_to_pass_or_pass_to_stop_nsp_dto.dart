import 'package:sfera/src/data/dto/general_jp_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/xml_stop_to_pass_or_pass_to_stop_dto.dart';

class StopToPassOrPassToStopNspDto extends GeneralJpInformationNspDto {
  static const String groupNameValue = 'stop2PassOrPass2Stop';

  StopToPassOrPassToStopNspDto({super.type, super.attributes, super.children, super.value});

  XmlStopToPassOrPassToStopDto get xmlStopToPassOrPassToStop =>
      children.whereType<XmlStopToPassOrPassToStopDto>().first;

  @override
  bool validate() {
    return super.validateHasChildOfType<XmlStopToPassOrPassToStopDto>() && super.validate();
  }
}

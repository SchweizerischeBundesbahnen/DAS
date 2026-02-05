import 'package:sfera/src/data/dto/general_jp_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/xml_stop_2_pass_or_pass_2_stop_dto.dart';

class Stop2PassOrPass2StopNspDto extends GeneralJpInformationNspDto {
  static const String groupNameValue = 'stop2PassOrPass2Stop';

  Stop2PassOrPass2StopNspDto({super.type, super.attributes, super.children, super.value});

  Iterable<XmlStop2PassOrPass2StopDto> get xmlStop2PassOrPass2Stop => children.whereType<XmlStop2PassOrPass2StopDto>();

  @override
  bool validate() {
    return super.validateHasChildOfType<XmlStop2PassOrPass2StopDto>() && super.validate();
  }
}

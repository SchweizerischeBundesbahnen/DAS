import 'package:sfera/src/data/dto/end_destination_change_nsp_dto.dart';
import 'package:sfera/src/data/dto/nsp_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/stop_to_pass_or_pass_to_stop_nsp_dto.dart';
import 'package:sfera/src/data/dto/tms_data_dto.dart';
import 'package:sfera/src/data/dto/train_run_rerouting_nsp_dto.dart';

class GeneralJpInformationNspDto extends NspDto {
  static const String elementType = 'General_JP_Information_NSP';

  GeneralJpInformationNspDto({super.type = elementType, super.attributes, super.children, super.value});

  factory GeneralJpInformationNspDto.from({
    Map<String, String>? attributes,
    List<SferaXmlElementDto>? children,
    String? value,
  }) {
    final groupName = children?.where((it) => it.type == NspDto.groupNameElement).firstOrNull;
    if (groupName?.value == TmsDataNspDto.groupNameValue) {
      return TmsDataNspDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == StopToPassOrPassToStopNspDto.groupNameValue) {
      return StopToPassOrPassToStopNspDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == TrainRunReroutingNspDto.groupNameValue) {
      return TrainRunReroutingNspDto(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == EndDestinationChangeNspDto.groupNameValue) {
      return EndDestinationChangeNspDto(attributes: attributes, children: children, value: value);
    }
    return GeneralJpInformationNspDto(attributes: attributes, children: children, value: value);
  }
}

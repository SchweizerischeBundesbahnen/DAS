import 'package:sfera/src/data/dto/nsp_dto.dart';
import 'package:sfera/src/data/dto/passing_point_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class TimingPointConstraintsNspDto extends NspDto {
  static const String elementType = 'TimingPointConstraints_NSPs';

  TimingPointConstraintsNspDto({super.type = elementType, super.attributes, super.children, super.value});

  factory TimingPointConstraintsNspDto.from({
    Map<String, String>? attributes,
    List<SferaXmlElementDto>? children,
    String? value,
  }) {
    final groupName = children?.where((it) => it.type == NspDto.groupNameElement).firstOrNull;
    if (groupName?.value == PassingPointInformationNspDto.groupNameValue) {
      return PassingPointInformationNspDto(attributes: attributes, children: children, value: value);
    }
    return TimingPointConstraintsNspDto(attributes: attributes, children: children, value: value);
  }
}

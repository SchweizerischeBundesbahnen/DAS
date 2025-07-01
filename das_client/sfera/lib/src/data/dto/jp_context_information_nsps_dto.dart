import 'package:sfera/src/data/dto/jp_contex_information_nsp_constraints.dart';
import 'package:sfera/src/data/dto/nsp_dto.dart';
import 'package:sfera/src/data/dto/operational_indication_nsp_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class JpContextInformationNspDto extends NspDto {
  static const String elementType = 'JP_ContextInformation_NSPs';

  JpContextInformationNspDto({super.type = elementType, super.attributes, super.children, super.value});

  factory JpContextInformationNspDto.from({
    Map<String, String>? attributes,
    List<SferaXmlElementDto>? children,
    String? value,
  }) {
    final groupName = children?.where((it) => it.type == NspDto.groupNameElement).firstOrNull;
    if (groupName?.value == OperationalIndicationNspDto.elementType) {
      return OperationalIndicationNspDto(attributes: attributes, children: children, value: value);
    }
    return JpContextInformationNspDto(attributes: attributes, children: children, value: value);
  }

  JpContexInformationNspConstraints? get constraints =>
      children.whereType<JpContexInformationNspConstraints>().firstOrNull;
}

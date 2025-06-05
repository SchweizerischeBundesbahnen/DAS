import 'package:sfera/src/data/dto/nsp_dto.dart';
import 'package:sfera/src/data/dto/parallel_asr_constraint_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class NetworkSpecificConstraintDto extends NspDto {
  static const String elementType = 'NetworkSpecificConstraint';

  NetworkSpecificConstraintDto({super.type = elementType, super.attributes, super.children, super.value});

  factory NetworkSpecificConstraintDto.from({
    Map<String, String>? attributes,
    List<SferaXmlElementDto>? children,
    String? value,
  }) {
    final groupName = children?.where((it) => it.type == NspDto.groupNameElement).firstOrNull;
    if (groupName?.value == ParallelAsrConstraintDto.elementType) {
      return ParallelAsrConstraintDto(attributes: attributes, children: children, value: value);
    }
    return NetworkSpecificConstraintDto(attributes: attributes, children: children, value: value);
  }
}

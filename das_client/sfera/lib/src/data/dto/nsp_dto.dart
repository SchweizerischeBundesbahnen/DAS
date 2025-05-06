import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

abstract class NspDto extends SferaXmlElementDto {
  static const String elementType = 'NSP';
  static const String groupNameElement = 'NSP_GroupName';

  NspDto({super.type = elementType, super.attributes, super.children, super.value});

  String? get groupName => childrenWithType(groupNameElement).firstOrNull?.value;

  String get company => childrenWithType('teltsi_Company').first.value!;

  Iterable<NetworkSpecificParameterDto> get parameters => children.whereType<NetworkSpecificParameterDto>();

  @override
  bool validate() {
    return validateHasChild('teltsi_Company') && validateHasChildOfType<NetworkSpecificParameterDto>() && super.validate();
  }
}

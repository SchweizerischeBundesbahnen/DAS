import 'package:sfera/src/data/dto/enums/modification_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

abstract class NspDto extends SferaXmlElementDto {
  static const String elementType = 'NSP';
  static const String groupNameElement = 'NSP_GroupName';

  NspDto({super.type = elementType, super.attributes, super.children, super.value});

  String? get groupName => childrenWithType(groupNameElement).firstOrNull?.value;

  String get company => childrenWithType('teltsi_Company').first.value!;

  Iterable<NetworkSpecificParameterDto> get parameters => children.whereType<NetworkSpecificParameterDto>();

  DateTime? get lastModificationDate => parameters
      .where((it) => it.name == 'lastModificationDate')
      .map((it) => DateTime.tryParse(it.value ?? ''))
      .firstOrNull;

  ModificationTypeDto? get lastModificationType => parameters
      .where((it) => it.name == 'lastModificationType')
      .map((it) => XmlEnum.valueOf(ModificationTypeDto.values, it.value))
      .nonNulls
      .firstOrNull;

  @override
  bool validate() {
    return validateHasChild('teltsi_Company') &&
        validateHasChildOfType<NetworkSpecificParameterDto>() &&
        super.validate();
  }
}

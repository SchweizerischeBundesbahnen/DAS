import 'package:sfera/src/data/dto/enums/operational_indication_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/jp_context_information_nsps_dto.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class OperationalIndicationNspDto extends JpContextInformationNspDto {
  static const String elementType = 'operationalIndication';

  OperationalIndicationNspDto({super.type = elementType, super.attributes, super.children, super.value});

  OperationalIndicationTypeDto? get operationalIndicationType => XmlEnum.valueOf<OperationalIndicationTypeDto>(
    OperationalIndicationTypeDto.values,
    parameters.withName('type')?.nspValue,
  );

  String? get uncodedText => parameters.withName('uncodedText')?.nspValue;
}

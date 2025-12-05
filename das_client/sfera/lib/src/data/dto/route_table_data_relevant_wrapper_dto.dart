import 'package:sfera/src/data/dto/enums/route_table_data_relevant_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class RouteTableDataRelevantWrapperDto extends NetworkSpecificParameterDto {
  static const String elementName = 'routeTableDataRelevant';

  RouteTableDataRelevantWrapperDto({super.type, super.attributes, super.children, super.value});

  RouteTableDataRelevantDto get unwrapped => XmlEnum.valueOf(RouteTableDataRelevantDto.values, nspValue)!;

  bool get isAdditional => unwrapped != .isTrue;

  @override
  bool validate() {
    return validateHasAttributeInRange('value', XmlEnum.values(RouteTableDataRelevantDto.values)) && super.validate();
  }
}

import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class SbbFunctionSignalDto extends NetworkSpecificParameterDto {
  static const String elementName = 'sbbFunction';

  SbbFunctionSignalDto({super.type, super.attributes, super.children, super.value});
}

import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class SbbFunctionSignalDto({super.type, super.attributes, super.children, super.value})
    extends NetworkSpecificParameterDto {
  static const String elementName = 'sbbFunction';
}

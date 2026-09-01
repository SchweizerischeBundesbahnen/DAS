import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class SpeedNetworkSpecificParameterDto({super.type, super.attributes, super.children, super.value})
    extends NetworkSpecificParameterDto {
  static const String elementName = 'speed';

  int get speed => int.parse(nspValue);

  @override
  bool validate() {
    return validateHasAttributeInt('value') && super.validate();
  }
}

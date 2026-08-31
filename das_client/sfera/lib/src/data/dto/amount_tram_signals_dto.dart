import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class AmountTramSignalsDto({super.type, super.attributes, super.children, super.value})
    extends NetworkSpecificParameterDto {
  static const String elementName = 'amountTramSignals';

  int get amountTramSignals => int.parse(attributes['value']!);

  @override
  bool validate() {
    return validateHasAttributeInt('value') && super.validate();
  }
}

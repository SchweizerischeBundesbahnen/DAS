import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class AmountTramSignalsDto extends NetworkSpecificParameterDto {
  static const String elementName = 'amountTramSignals';

  AmountTramSignalsDto({super.type, super.attributes, super.children, super.value});

  int get amountTramSignals => int.parse(attributes['value']!);

  @override
  bool validate() {
    return validateHasAttributeInt('value') && super.validate();
  }
}

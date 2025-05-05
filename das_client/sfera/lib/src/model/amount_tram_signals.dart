import 'package:sfera/src/model/network_specific_parameter.dart';

class AmountTramSignals extends NetworkSpecificParameter {
  static const String elementName = 'amountTramSignals';

  AmountTramSignals({super.type, super.attributes, super.children, super.value});

  int get amountTramSignals => int.parse(attributes['value']!);

  @override
  bool validate() {
    return validateHasAttributeInt('value') && super.validate();
  }
}

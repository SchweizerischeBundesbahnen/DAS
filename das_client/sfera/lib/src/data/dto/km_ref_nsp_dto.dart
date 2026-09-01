import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class KmRefNspDto({super.type, super.attributes, super.children, super.value}) extends NetworkSpecificParameterDto {
  static const String elementName = 'kmRef';

  double get kmRef => double.parse(attributes['value']!);

  @override
  bool validate() {
    return validateHasAttributeDouble('value') && super.validate();
  }
}

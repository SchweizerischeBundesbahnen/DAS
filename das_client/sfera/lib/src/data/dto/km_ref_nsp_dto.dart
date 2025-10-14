import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class KmRefNspDto extends NetworkSpecificParameterDto {
  static const String elementName = 'kmRef';

  KmRefNspDto({super.type, super.attributes, super.children, super.value});

  double get kmRef => double.parse(attributes['value']!);

  @override
  bool validate() {
    return validateHasAttributeDouble('value') && super.validate();
  }
}

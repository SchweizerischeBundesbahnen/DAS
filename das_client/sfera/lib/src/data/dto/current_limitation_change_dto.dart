import 'package:sfera/src/data/dto/current_limitation_start_dto.dart';

class CurrentLimitationChangeDto({super.type = elementType, super.attributes, super.children, super.value})
    extends CurrentLimitationStartDto {
  static const String elementType = 'CurrentLimitationChange';

  double get location => double.parse(attributes['location']!);

  @override
  bool validate() {
    return validateHasAttributeDouble('location') && super.validate();
  }
}

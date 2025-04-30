import 'package:app/sfera/src/model/current_limitation_start.dart';

class CurrentLimitationChange extends CurrentLimitationStart {
  static const String elementType = 'CurrentLimitationChange';

  CurrentLimitationChange({super.type = elementType, super.attributes, super.children, super.value});

  double get location => double.parse(attributes['location']!);

  @override
  bool validate() {
    return validateHasAttributeDouble('location') && super.validate();
  }
}

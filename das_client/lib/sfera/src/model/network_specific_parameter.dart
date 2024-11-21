import 'package:das_client/sfera/src/model/sp_generic_point.dart';

class NetworkSpecificParameter extends SpGenericPoint {
  static const String elementType = 'NetworkSpecificParameter';

  NetworkSpecificParameter({super.type = elementType, super.attributes, super.children, super.value});

  String get name => attributes['name']!;

  String get nspValue => attributes['value']!;

  @override
  bool validate() {
    return validateHasAttribute('name') && validateHasAttribute('value') && super.validate();
  }
}

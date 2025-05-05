import 'package:sfera/src/model/km_reference.dart';
import 'package:sfera/src/model/sp_generic_point.dart';

class KilometreReferencePoint extends SpGenericPoint {
  static const String elementType = 'KilometreReferencePoint';

  KilometreReferencePoint({super.type = elementType, super.attributes, super.children, super.value});

  KmReference get kmReference => children.whereType<KmReference>().first;

  @override
  bool validate() {
    return validateHasChildOfType<KmReference>() && super.validate();
  }
}

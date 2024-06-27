import 'package:fimber/fimber.dart';

class SferaXmlElement {
  final String type;
  final Map<String, dynamic> attributes;
  final List<SferaXmlElement> children;
  final String? value;

  SferaXmlElement({required this.type, Map<String, dynamic>? attributes, List<SferaXmlElement>? children, this.value})
      : attributes = attributes ?? {},
        children = children ?? [];

  bool validate() {
    return children.every((it) => it.validate());
  }

  bool validateHasAttribute(String attribute) {
    if (!attributes.containsKey(attribute)) {
      Fimber.w("Validation failed for $type because attribute $attribute is missing");
      return false;
    }

    return true;
  }

  bool validateHasChild(String type) {
    if (children.where((it) => it.type == type).isEmpty) {
      Fimber.w("Validation failed for ${this.type} because it has no child of type $type");
      return false;
    }

    return true;
  }

  bool validateHasChildOfType<T>() {
    if (children.whereType<T>().isEmpty) {
      Fimber.w("Validation failed for ${this.type} because it has no child of type ${T.toString()}");
      return false;
    }

    return true;
  }

  Iterable<SferaXmlElement> childrenWithType(String type) {
    return children.where((it) => it.type == type);
  }
}

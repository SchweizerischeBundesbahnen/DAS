import 'package:fimber/fimber.dart';
import 'package:xml/xml.dart';

class SferaXmlElement {
  final String type;
  final Map<String, String> attributes;
  final List<SferaXmlElement> children;
  final String? value;

  SferaXmlElement({required this.type, Map<String, String>? attributes, List<SferaXmlElement>? children, this.value})
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
    if (childrenWithType(type).isEmpty) {
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

  XmlDocument buildDocument() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    buildElement(builder);
    return builder.buildDocument();
  }

  void buildElement(XmlBuilder builder) {
    builder.element(type, nest: () {
      attributes.forEach((k, v) {
        builder.attribute(k, v);
      });
      for (var child in children) {
        child.buildElement(builder);
      }
      if (value != null) {
        builder.text(value!);
      }
    });
  }
}

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class SferaXmlElementDto {
  final String type;
  final Map<String, String> attributes;
  final List<SferaXmlElementDto> children;
  final String? value;

  SferaXmlElementDto({required this.type, Map<String, String>? attributes, List<SferaXmlElementDto>? children, this.value})
      : attributes = attributes ?? {},
        children = children ?? [];

  @mustCallSuper
  bool validate() {
    return children.every((it) => it.validate());
  }

  bool validateIsNotNull(dynamic object) {
    if (object == null) {
      Fimber.w('Validation failed for $type because required object is null');
      return false;
    }

    return true;
  }

  bool validateHasAttribute(String attribute) {
    if (!attributes.containsKey(attribute)) {
      Fimber.w('Validation failed for $type because attribute $attribute is missing');
      return false;
    }

    return true;
  }

  bool validateHasAttributeInRange(String attribute, List<String> allValues) {
    if (allValues.where((it) => it.toLowerCase() == attributes[attribute]?.toLowerCase()).isEmpty) {
      Fimber.w(
          'Validation failed for $type because attribute $attribute with value "${attributes[attribute]}" could not be mapped to any of ${allValues.join(",")}');
      return false;
    }

    return true;
  }

  bool validateHasAttributeDouble(String attribute) {
    if (!attributes.containsKey(attribute)) {
      Fimber.w('Validation failed for $type because attribute=$attribute is missing');
      return false;
    }

    if (double.tryParse(attributes[attribute]!) == null) {
      Fimber.w(
          'Validation failed for $type because attribute=$attribute with value=${attributes[attribute]} could not be parsed to double');
      return false;
    }

    return true;
  }

  bool validateHasAttributeInt(String attribute) {
    if (!attributes.containsKey(attribute)) {
      Fimber.w('Validation failed for $type because attribute=$attribute is missing');
      return false;
    }

    if (int.tryParse(attributes[attribute]!) == null) {
      Fimber.w(
          'Validation failed for $type because attribute=$attribute with value=${attributes[attribute]} could not be parsed to int');
      return false;
    }

    return true;
  }

  bool validateHasChild(String type) {
    if (childrenWithType(type).isEmpty) {
      Fimber.w('Validation failed for ${this.type} because it has no child of type $type');
      return false;
    }

    return true;
  }

  bool validateHasChildInt(String type) {
    if (!validateHasChild(type)) {
      return false;
    }

    final childValue = childrenWithType(type).first.value;

    if (childValue == null || int.tryParse(childValue) == null) {
      Fimber.w(
          'Validation failed for ${this.type} because child of type=$type with value=$childValue could not be parsed to int');
      return false;
    }

    return true;
  }

  bool validateHasChildOfType<T>() {
    if (children.whereType<T>().isEmpty) {
      Fimber.w('Validation failed for $type because it has no child of type ${T.toString()}');
      return false;
    }

    return true;
  }

  bool validateHasAnyChildOfType(List<String> types) {
    if (!children.map((it) => it.type).any((it) => types.contains(it))) {
      Fimber.w("Validation failed for $type because it has no child of any type: ${types.join(", ")}");
      return false;
    }

    return true;
  }

  Iterable<SferaXmlElementDto> childrenWithType(String type) {
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
      for (final child in children) {
        child.buildElement(builder);
      }
      if (value != null) {
        builder.text(value!);
      }
    });
  }

  @override
  String toString() {
    return buildDocument().toString();
  }
}

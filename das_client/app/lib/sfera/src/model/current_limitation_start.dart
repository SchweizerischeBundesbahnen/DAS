import 'package:app/sfera/src/model/sfera_xml_element.dart';

class CurrentLimitationStart extends SferaXmlElement {
  static const String elementType = 'CurrentLimitationStart';

  CurrentLimitationStart({super.type = elementType, super.attributes, super.children, super.value});

  String get maxCurValue => attributes['maxCurValue']!;

  @override
  bool validate() {
    return validateHasAttribute('maxCurValue') && super.validate();
  }
}

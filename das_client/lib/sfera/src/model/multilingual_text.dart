import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class MultilingualText extends SferaXmlElement {
  static const String elementType = 'MultilingualText';

  MultilingualText({super.type = elementType, super.attributes, super.children, super.value});

  String get language => attributes['language']!;

  String get messageString => attributes['messageString']!;

  @override
  bool validate() {
    return validateHasAttribute('language') && validateHasAttribute('messageString') && super.validate();
  }
}

// extensions

extension MultilingualTextsExtension on Iterable<MultilingualText> {
  String? messageFor(String locale) => where((it) => it.language == locale).firstOrNull?.messageString;
}

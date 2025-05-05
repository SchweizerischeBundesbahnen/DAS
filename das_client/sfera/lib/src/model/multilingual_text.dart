import 'package:sfera/src/model/sfera_xml_element.dart';

class MultilingualText extends SferaXmlElement {
  static const String elementType = 'MultilingualText';

  MultilingualText({super.type = elementType, super.attributes, super.children, super.value});

  String get language => attributes['language']!;

  String get text => attributes['text']!;

  @override
  bool validate() {
    return validateHasAttribute('language') && validateHasAttribute('text') && super.validate();
  }
}

// extensions

extension MultilingualTextsExtension on Iterable<MultilingualText> {
  String? textFor(String locale) => where((it) => it.language == locale).firstOrNull?.text;
}

import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class MultilingualTextDto extends SferaXmlElementDto {
  static const String elementType = 'MultilingualText';

  MultilingualTextDto({super.type = elementType, super.attributes, super.children, super.value});

  String get language => attributes['language']!;

  String get text => attributes['text']!;

  @override
  bool validate() {
    return validateHasAttribute('language') && validateHasAttribute('text') && super.validate();
  }
}

// extensions

extension MultilingualTextsExtension on Iterable<MultilingualTextDto> {
  String? textFor(String locale) => where((it) => it.language == locale).firstOrNull?.text;
}

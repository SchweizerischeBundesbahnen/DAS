import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/model/localized_string.dart';

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

extension MultilingualTextsExtension on Iterable<MultilingualTextDto> {
  String? textFor(String locale) => where((it) => it.language.toLowerCase() == locale.toLowerCase()).firstOrNull?.text;

  LocalizedString? get toLocalizedString {
    if (isEmpty) {
      return null;
    }

    return LocalizedString(
      de: textFor('de'),
      fr: textFor('fr'),
      it: textFor('it'),
    );
  }
}

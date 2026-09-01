import 'package:sfera/src/data/dto/multilingual_text_dto.dart';

class AdditionalInfoDto({super.type = elementType, super.attributes, super.children, super.value})
    extends MultilingualTextDto {
  static const String elementType = 'AdditionalInfo';

  @override
  String toString() {
    return 'AdditionalInfoDto{language: $language, text: $text}';
  }
}

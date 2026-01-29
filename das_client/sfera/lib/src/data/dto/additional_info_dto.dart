import 'package:sfera/src/data/dto/multilingual_text_dto.dart';

class AdditionalInfoDto extends MultilingualTextDto {
  static const String elementType = 'AdditionalInfo';

  AdditionalInfoDto({super.type = elementType, super.attributes, super.children, super.value});

  @override
  String toString() {
    return 'AdditionalInfoDto{language: $language, text: $text}';
  }
}

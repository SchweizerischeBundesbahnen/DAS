import 'package:sfera/src/data/dto/multilingual_text_dto.dart';

class ReasonTextDto extends MultilingualTextDto {
  static const String elementType = 'ReasonText';

  ReasonTextDto({super.type = elementType, super.attributes, super.children, super.value});
}

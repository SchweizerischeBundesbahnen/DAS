import 'package:sfera/src/data/dto/multilingual_text_dto.dart';

class TemporaryConstraintReasonDto extends MultilingualTextDto {
  static const String elementType = 'TemporaryConstraintReason';

  TemporaryConstraintReasonDto({super.type = elementType, super.attributes, super.children, super.value});
}

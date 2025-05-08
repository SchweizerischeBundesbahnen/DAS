import 'package:sfera/src/data/dto/multilingual_text_dto.dart';

class ConnectionTrackDescriptionDto extends MultilingualTextDto {
  static const String elementType = 'ConnectionTrackDescription';

  ConnectionTrackDescriptionDto({super.type = elementType, super.attributes, super.children, super.value});
}

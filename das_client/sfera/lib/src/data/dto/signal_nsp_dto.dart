import 'package:sfera/src/data/dto/nsp_dto.dart';

class SignalNspDto extends NspDto {
  static const String elementType = 'Signal_NSPs';

  SignalNspDto({super.type = elementType, super.attributes, super.children, super.value});
}

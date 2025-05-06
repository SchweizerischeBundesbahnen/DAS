import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/signal_function_dto.dart';
import 'package:sfera/src/data/dto/signal_id_dto.dart';
import 'package:sfera/src/data/dto/signal_physical_characteristics_dto.dart';

class SignalDto extends SferaXmlElementDto {
  static const String elementType = 'Signal';

  SignalDto({super.type = elementType, super.attributes, super.children, super.value});

  SignalIdDto get id => children.whereType<SignalIdDto>().first;

  SignalPhysicalCharacteristicsDto? get physicalCharacteristics =>
      children.whereType<SignalPhysicalCharacteristicsDto>().firstOrNull;

  Iterable<SignalFunctionDto> get functions => children.whereType<SignalFunctionDto>();

  @override
  bool validate() {
    return validateHasChildOfType<SignalIdDto>() && super.validate();
  }
}

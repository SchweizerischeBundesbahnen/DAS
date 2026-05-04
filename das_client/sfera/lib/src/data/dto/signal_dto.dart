import 'package:sfera/src/data/dto/enums/modification_type_dto.dart';
import 'package:sfera/src/data/dto/sbb_function_signal_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/signal_function_dto.dart';
import 'package:sfera/src/data/dto/signal_id_dto.dart';
import 'package:sfera/src/data/dto/signal_nsp_dto.dart';
import 'package:sfera/src/data/dto/signal_physical_characteristics_dto.dart';
import 'package:sfera/src/data/parser/parse_utils.dart';

class SignalDto extends SferaXmlElementDto {
  static const String elementType = 'Signal';

  SignalDto({super.type = elementType, super.attributes, super.children, super.value});

  SignalIdDto get id => children.whereType<SignalIdDto>().first;

  SignalPhysicalCharacteristicsDto? get physicalCharacteristics =>
      children.whereType<SignalPhysicalCharacteristicsDto>().firstOrNull;

  Iterable<SignalFunctionDto> get functions => children.whereType<SignalFunctionDto>().followedBy(nspFunctions);

  Iterable<SignalNspDto> get nsps => children.whereType<SignalNspDto>();

  DateTime? get lastModificationDate => nsps.map((it) => it.lastModificationDate).nonNulls.firstOrNull;

  double? get km => ParseUtils.tryParseDouble(
    nsps
        .where((it) => it.groupName == 'routeTableData')
        .map((it) => it.parameters.where((param) => param.name == 'km').firstOrNull)
        .firstOrNull
        ?.nspValue,
  );

  ModificationTypeDto? get lastModificationType => nsps.map((it) => it.lastModificationType).nonNulls.firstOrNull;

  Iterable<SignalFunctionDto> get nspFunctions => nsps
      .map((it) => it.parameters.whereType<SbbFunctionSignalDto>())
      .expand((it) => it)
      .map((it) => SignalFunctionDto(value: it.nspValue))
      .nonNulls;

  @override
  bool validate() {
    return validateHasChildOfType<SignalIdDto>() && super.validate();
  }
}

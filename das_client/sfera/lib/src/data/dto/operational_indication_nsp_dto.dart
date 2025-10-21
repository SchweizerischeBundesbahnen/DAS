import 'package:sfera/src/data/dto/enums/operational_indication_type_dto.dart';
import 'package:sfera/src/data/dto/jp_context_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/operational_indication_type_nsp_dto.dart';
import 'package:sfera/src/data/dto/operational_indication_uncoded_text_nsp_dto.dart';

class OperationalIndicationNspDto extends JpContextInformationNspDto {
  static const String elementName = 'operationalIndication';

  OperationalIndicationNspDto({super.type, super.attributes, super.children, super.value});

  OperationalIndicationTypeDto get operationalIndicationType =>
      children.whereType<OperationalIndicationTypeNspDto>().first.operationalIndicationType;

  String get uncodedText => children.whereType<OperationalIndicationUncodedTextNspDto>().first.text;

  @override
  bool validate() =>
      validateHasChildOfType<OperationalIndicationUncodedTextNspDto>() &&
      validateHasChildOfType<OperationalIndicationTypeNspDto>() &&
      super.validate();
}

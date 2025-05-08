import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class AdditionalSpeedRestrictionDto extends SferaXmlElementDto {
  static const String elementType = 'AdditionalSpeedRestriction';

  AdditionalSpeedRestrictionDto({super.type = elementType, super.attributes, super.children, super.value});

  bool get asrFront => attributes['ASR_Front'] != null ? bool.tryParse(attributes['ASR_Front']!) ?? false : false;

  int? get asrSpeed => attributes['ASR_Speed'] != null ? int.tryParse(attributes['ASR_Speed']!) : null;
}

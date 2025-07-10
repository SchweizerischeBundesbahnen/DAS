import 'package:sfera/src/data/dto/advice_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/reason_code_dto.dart';
import 'package:sfera/src/data/dto/reason_text_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class AdvisedSpeedDto extends SferaXmlElementDto {
  static const String elementType = 'AdvisedSpeed';

  AdvisedSpeedDto({super.type = elementType, super.attributes, super.children, super.value});

  String? get speed => attributes['optimalSpeed'] ?? attributes['speed'];

  ReasonCodeDto? get reasonCode => XmlEnum.valueOf(ReasonCodeDto.values, attributes['reasonCode']);

  ReasonTextDto? get reasonText => children.whereType<ReasonTextDto>().firstOrNull;

  /// 0 in case the train shall drive as fast as allowed, only provided if the train shall drive as fast as allowed
  /// => Vmax AdvisedSpeed
  String? get deltaSpeed => attributes['deltaSpeed'];

  AdviceTypeDto get adviceType => XmlEnum.valueOf(AdviceTypeDto.values, attributes['adviceType'])!;

  @override
  bool validate() {
    return super.validate() && validateHasAttribute('adviceType');
  }
}

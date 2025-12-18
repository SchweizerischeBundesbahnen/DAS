import 'package:sfera/src/data/dto/additional_info_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class G2bErrorDto extends SferaXmlElementDto {
  static const String elementType = 'G2B_Error';

  G2bErrorDto({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<AdditionalInfoDto> get additionalInfos => children.whereType<AdditionalInfoDto>();

  String? get errorCode => attributes['errorCode'];

  String? get xPath => attributes['XPath'];

  // TODO: dataFirstAvailable

  @override
  String toString() {
    return 'G2bErrorDto{errorCode: $errorCode, xPath: $xPath, additionalInfos: $additionalInfos}';
  }
}

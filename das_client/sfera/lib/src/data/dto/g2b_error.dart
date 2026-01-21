import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/additional_info_dto.dart';
import 'package:sfera/src/data/dto/multilingual_text_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class G2bErrorDto extends SferaXmlElementDto {
  static const String elementType = 'G2B_Error';

  G2bErrorDto({super.type = elementType, super.attributes, super.children, super.value});

  Iterable<AdditionalInfoDto> get additionalInfos => children.whereType<AdditionalInfoDto>();

  String? get errorCode => attributes['errorCode'];

  String? get xPath => attributes['XPath'];

  DateTime? get dataFirstAvailable =>
      attributes['dataFirstAvailable'] != null ? DateTime.tryParse(attributes['dataFirstAvailable']!) : null;

  @override
  String toString() {
    return 'G2bErrorDto{errorCode: $errorCode, xPath: $xPath, dataFirstAvailable: $dataFirstAvailable, additionalInfos: $additionalInfos}';
  }
}

extension G2bErrorMapperExtension on G2bErrorDto {
  ProtocolError get toProtocolError =>
      ProtocolError(code: errorCode ?? 'Unknown', additionalInfo: additionalInfos.toLocalizedString);
}

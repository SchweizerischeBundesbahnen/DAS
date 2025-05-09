import 'package:sfera/src/data/dto/das_operating_modes_supported_dto.dart';
import 'package:sfera/src/data/dto/enums/related_train_request_type_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class HandshakeRequestDto extends SferaXmlElementDto {
  static const String elementType = 'HandshakeRequest';

  HandshakeRequestDto({super.type = elementType, super.attributes, super.children, super.value});

  factory HandshakeRequestDto.create(Iterable<DasOperatingModesSupportedDto> supportedOperatingModes,
      {bool? statusReportsEnabled, String? additionalInfo, RelatedTrainRequestTypeDto? relatedTrainRequestType}) {
    final request = HandshakeRequestDto();
    request.children.addAll(supportedOperatingModes);
    if (relatedTrainRequestType != null) {
      request.attributes['relatedTrainRequest'] = relatedTrainRequestType.xmlValue;
    }
    if (statusReportsEnabled != null) {
      request.attributes['statusReportsEnabled'] = statusReportsEnabled.toString();
    }
    if (additionalInfo != null) {
      request.attributes['additionalInfo'] = additionalInfo;
    }
    return request;
  }
}

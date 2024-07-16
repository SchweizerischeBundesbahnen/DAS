import 'package:das_client/model/sfera/das_operating_modes_supported.dart';
import 'package:das_client/model/sfera/enums/related_train_request_type.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';

class HandshakeRequest extends SferaXmlElement {
  static const String elementType = "HandshakeRequest";

  HandshakeRequest({super.type = elementType, super.attributes, super.children, super.value});

  factory HandshakeRequest.create(Iterable<DasOperatingModesSupported> supportedOperatingModes,
      {bool? statusReportsEnabled, String? additionalInfo, RelatedTrainRequestType? relatedTrainRequestType}) {
    final request = HandshakeRequest();
    request.children.addAll(supportedOperatingModes);
    if (relatedTrainRequestType != null) {
      request.attributes["relatedTrainRequest"] = relatedTrainRequestType.xmlValue;
    }
    if (statusReportsEnabled != null) {
      request.attributes["statusReportsEnabled"] = statusReportsEnabled.toString();
    }
    if (additionalInfo != null) {
      request.attributes["additionalInfo"] = additionalInfo;
    }
    return request;
  }
}

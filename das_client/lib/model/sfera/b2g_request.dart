import 'package:das_client/model/sfera/jp_request.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:das_client/model/sfera/sp_request.dart';

class B2gRequest extends SferaXmlElement {
  static const String elementType = "B2G_Request";

  B2gRequest({super.type = elementType, super.attributes, super.children, super.value});

  factory B2gRequest.createJPRequest(JpRequest jpRequest) {
    final request = B2gRequest();
    request.children.add(jpRequest);
    return request;
  }

  factory B2gRequest.createSPRequest(List<SpRequest> spRequests) {
    final request = B2gRequest();
    for (final spRequest in spRequests) {
      request.children.add(spRequest);
    }
    return request;
  }
}

import 'package:sfera/src/data/dto/sfera_xml_element.dart';

class TcRequest extends SferaXmlElement {
  static const String elementType = 'TC_Request';

  TcRequest({super.type = elementType, super.attributes, super.children, super.value});

  factory TcRequest.create(
      {required String id, required String versionMajor, required String versionMinor, required String ruId}) {
    final request = TcRequest();
    request.attributes['TC_ID'] = id;
    request.attributes['TC_VersionMajor'] = versionMajor;
    request.attributes['TC_VersionMinor'] = versionMinor;
    request.children.add(SferaXmlElement(type: 'TC_RU_ID', value: ruId));
    return request;
  }
}

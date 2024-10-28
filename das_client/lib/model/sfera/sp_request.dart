import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:das_client/model/sfera/sp_zone.dart';

class SpRequest extends SferaXmlElement {
  static const String elementType = "SP_Request";

  SpRequest({super.type = elementType, super.attributes, super.children, super.value});

  factory SpRequest.create({required String id, required String versionMajor, required String versionMinor, required SpZone spZone}) {
    final request = SpRequest();
    request.attributes["SP_ID"] = id;
    request.attributes["SP_VersionMajor"] = versionMajor;
    request.attributes["SP_VersionMinor"] = versionMinor;
    request.children.add(spZone);
    return request;
  }
}

import 'package:das_client/model/sfera/enums/handshake_reject_reason.dart';
import 'package:das_client/model/sfera/enums/xml_enum.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:das_client/model/sfera/sp_zone.dart';

class HandshakeReject extends SferaXmlElement {
  static const String elementType = "HandshakeReject";

  HandshakeReject({super.type = elementType, super.attributes, super.children, super.value});

  SpZone? get spZone => children.whereType<SpZone>().firstOrNull;

  String? get atotsId => attributes["ATOTS_ID"];

  HandshakeRejectReason? get handshakeRejectReason =>
      XmlEnum.valueOf(HandshakeRejectReason.values, attributes["handshakeRejectReason"]);
}

import 'package:das_client/model/sfera/g2b_reply_payload.dart';
import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/message_header.dart';
import 'package:das_client/model/sfera/otn_id.dart';
import 'package:das_client/model/sfera/segment_profile_list.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:das_client/model/sfera/sfera_g2b_reply_message.dart';
import 'package:das_client/model/sfera/train_identification.dart';
import 'package:xml/xml.dart';

class SferaReplyParser {
  SferaReplyParser._();

  static SferaG2bReplyMessage parse(String input) {
    var xmlDocument = XmlDocument.parse(input);
    var xml = _parseXml(xmlDocument.rootElement);
    return xml as SferaG2bReplyMessage;
  }

  static SferaXmlElement _parseXml(XmlElement xmlElement) {
    var attributes = <String, dynamic>{};
    var children = <SferaXmlElement>[];

    for (var attribute in xmlElement.attributes) {
      attributes[attribute.name.toString()] = attribute.value;
    }

    for (var childElement in xmlElement.childElements) {
      var child = _parseXml(childElement);
      children.add(child);
    }

    var xmlTextElements = xmlElement.children.whereType<XmlText>();

    return _createResolvedType(xmlElement.name.toString(), attributes, children,
        xmlTextElements.length == 1 ? xmlTextElements.first.toString() : null);
  }

  static SferaXmlElement _createResolvedType(
      String type, Map<String, dynamic> attributes, List<SferaXmlElement> children, String? value) {
    switch (type) {
      case SferaG2bReplyMessage.elementType:
        return SferaG2bReplyMessage(type: type, attributes: attributes, children: children, value: value);
      case G2bReplyPayload.elementType:
        return G2bReplyPayload(type: type, attributes: attributes, children: children, value: value);
      case MessageHeader.elementType:
        return MessageHeader(type: type, attributes: attributes, children: children, value: value);
      case JourneyProfile.elementType:
        return JourneyProfile(type: type, attributes: attributes, children: children, value: value);
      case SegmentProfileList.elementType:
        return SegmentProfileList(type: type, attributes: attributes, children: children, value: value);
      case OtnId.elementType:
        return OtnId(type: type, attributes: attributes, children: children, value: value);
      case TrainIdentification.elementType:
        return TrainIdentification(type: type, attributes: attributes, children: children, value: value);
      default:
        return SferaXmlElement(type: type, attributes: attributes, children: children, value: value);
    }
  }
}

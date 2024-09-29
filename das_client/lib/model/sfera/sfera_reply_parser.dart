import 'package:das_client/model/sfera/das_operating_modes_selected.dart';
import 'package:das_client/model/sfera/g2b_reply_payload.dart';
import 'package:das_client/model/sfera/handshake_acknowledgement.dart';
import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/message_header.dart';
import 'package:das_client/model/sfera/otn_id.dart';
import 'package:das_client/model/sfera/segment_profile.dart';
import 'package:das_client/model/sfera/segment_profile_list.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';
import 'package:das_client/model/sfera/sfera_g2b_reply_message.dart';
import 'package:das_client/model/sfera/signal.dart';
import 'package:das_client/model/sfera/signal_id.dart';
import 'package:das_client/model/sfera/sp_points.dart';
import 'package:das_client/model/sfera/sp_zone.dart';
import 'package:das_client/model/sfera/stopping_point_information.dart';
import 'package:das_client/model/sfera/timing_point.dart';
import 'package:das_client/model/sfera/timing_point_constraints.dart';
import 'package:das_client/model/sfera/timing_point_reference.dart';
import 'package:das_client/model/sfera/tp_id_reference.dart';
import 'package:das_client/model/sfera/tp_name.dart';
import 'package:das_client/model/sfera/train_identification.dart';
import 'package:das_client/model/sfera/virtual_balise.dart';
import 'package:das_client/model/sfera/virtual_balise_position.dart';
import 'package:xml/xml.dart';

class SferaReplyParser {
  SferaReplyParser._();

  static T parse<T extends SferaXmlElement>(String input) {
    var xmlDocument = XmlDocument.parse(input);
    var xml = _parseXml(xmlDocument.rootElement);
    return xml as T;
  }

  static SferaXmlElement _parseXml(XmlElement xmlElement) {
    var attributes = <String, String>{};
    var children = <SferaXmlElement>[];

    for (var attribute in xmlElement.attributes) {
      attributes[attribute.name.toString()] = attribute.value;
    }

    for (var childElement in xmlElement.childElements) {
      var child = _parseXml(childElement);
      children.add(child);
    }

    var xmlTextElements = xmlElement.children.whereType<XmlText>();

    return _createResolvedType(xmlElement.name.toString(), Map.unmodifiable(attributes), List.unmodifiable(children),
        xmlTextElements.length == 1 ? xmlTextElements.first.toString() : null);
  }

  static SferaXmlElement _createResolvedType(
      String type, Map<String, String> attributes, List<SferaXmlElement> children, String? value) {
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
      case SpZone.elementType:
        return SpZone(type: type, attributes: attributes, children: children, value: value);
      case TimingPointConstraints.elementType:
        return TimingPointConstraints(type: type, attributes: attributes, children: children, value: value);
      case TimingPointReference.elementType:
        return TimingPointReference(type: type, attributes: attributes, children: children, value: value);
      case TpIdReference.elementType:
        return TpIdReference(type: type, attributes: attributes, children: children, value: value);
      case StoppingPointInformation.elementType:
        return StoppingPointInformation(type: type, attributes: attributes, children: children, value: value);
      case SegmentProfile.elementType:
        return SegmentProfile(type: type, attributes: attributes, children: children, value: value);
      case SpPoints.elementType:
        return SpPoints(type: type, attributes: attributes, children: children, value: value);
      case TimingPoint.elementType:
        return TimingPoint(type: type, attributes: attributes, children: children, value: value);
      case TpName.elementType:
        return TpName(type: type, attributes: attributes, children: children, value: value);
      case Signal.elementType:
        return Signal(type: type, attributes: attributes, children: children, value: value);
      case SignalId.elementType:
        return SignalId(type: type, attributes: attributes, children: children, value: value);
      case VirtualBalise.elementType:
        return VirtualBalise(type: type, attributes: attributes, children: children, value: value);
      case VirtualBalisePosition.elementType:
        return VirtualBalisePosition(type: type, attributes: attributes, children: children, value: value);
      case HandshakeAcknowledgement.elementType:
        return HandshakeAcknowledgement(type: type, attributes: attributes, children: children, value: value);
      case DasOperatingModesSelected.elementType:
        return DasOperatingModesSelected(type: type, attributes: attributes, children: children, value: value);
      default:
        return SferaXmlElement(type: type, attributes: attributes, children: children, value: value);
    }
  }
}

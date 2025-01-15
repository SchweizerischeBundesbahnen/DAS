import 'package:das_client/sfera/src/model/additional_speed_restriction.dart';
import 'package:das_client/sfera/src/model/balise.dart';
import 'package:das_client/sfera/src/model/connection_track.dart';
import 'package:das_client/sfera/src/model/current_limitation.dart';
import 'package:das_client/sfera/src/model/current_limitation_change.dart';
import 'package:das_client/sfera/src/model/current_limitation_start.dart';
import 'package:das_client/sfera/src/model/curve_speed.dart';
import 'package:das_client/sfera/src/model/das_operating_modes_selected.dart';
import 'package:das_client/sfera/src/model/g2b_reply_payload.dart';
import 'package:das_client/sfera/src/model/graduated_speed_info.dart';
import 'package:das_client/sfera/src/model/graduated_speed_info_entity.dart';
import 'package:das_client/sfera/src/model/handshake_acknowledgement.dart';
import 'package:das_client/sfera/src/model/handshake_reject.dart';
import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/kilometre_reference_point.dart';
import 'package:das_client/sfera/src/model/km_reference.dart';
import 'package:das_client/sfera/src/model/level_crossing_area.dart';
import 'package:das_client/sfera/src/model/line_speed.dart';
import 'package:das_client/sfera/src/model/location_ident.dart';
import 'package:das_client/sfera/src/model/message_header.dart';
import 'package:das_client/sfera/src/model/multilingual_text.dart';
import 'package:das_client/sfera/src/model/network_specific_area.dart';
import 'package:das_client/sfera/src/model/network_specific_parameter.dart';
import 'package:das_client/sfera/src/model/network_specific_point.dart';
import 'package:das_client/sfera/src/model/otn_id.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';
import 'package:das_client/sfera/src/model/segment_profile_list.dart';
import 'package:das_client/sfera/src/model/sfera_g2b_reply_message.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/signal.dart';
import 'package:das_client/sfera/src/model/signal_function.dart';
import 'package:das_client/sfera/src/model/signal_id.dart';
import 'package:das_client/sfera/src/model/signal_physical_characteristics.dart';
import 'package:das_client/sfera/src/model/sp_areas.dart';
import 'package:das_client/sfera/src/model/sp_characteristics.dart';
import 'package:das_client/sfera/src/model/sp_context_information.dart';
import 'package:das_client/sfera/src/model/sp_points.dart';
import 'package:das_client/sfera/src/model/sp_zone.dart';
import 'package:das_client/sfera/src/model/speeds.dart';
import 'package:das_client/sfera/src/model/station_speed.dart';
import 'package:das_client/sfera/src/model/stop_type.dart';
import 'package:das_client/sfera/src/model/stopping_point_information.dart';
import 'package:das_client/sfera/src/model/taf_tap_location.dart';
import 'package:das_client/sfera/src/model/taf_tap_location_ident.dart';
import 'package:das_client/sfera/src/model/taf_tap_location_name.dart';
import 'package:das_client/sfera/src/model/taf_tap_location_nsp.dart';
import 'package:das_client/sfera/src/model/taf_tap_location_reference.dart';
import 'package:das_client/sfera/src/model/tc_features.dart';
import 'package:das_client/sfera/src/model/temporary_constraint_reason.dart';
import 'package:das_client/sfera/src/model/temporary_constraints.dart';
import 'package:das_client/sfera/src/model/timing_point.dart';
import 'package:das_client/sfera/src/model/timing_point_constraints.dart';
import 'package:das_client/sfera/src/model/timing_point_reference.dart';
import 'package:das_client/sfera/src/model/tp_id_reference.dart';
import 'package:das_client/sfera/src/model/tp_name.dart';
import 'package:das_client/sfera/src/model/train_characteristics.dart';
import 'package:das_client/sfera/src/model/train_characteristics_ref.dart';
import 'package:das_client/sfera/src/model/train_identification.dart';
import 'package:das_client/sfera/src/model/velocity.dart';
import 'package:das_client/sfera/src/model/virtual_balise.dart';
import 'package:das_client/sfera/src/model/virtual_balise_position.dart';
import 'package:xml/xml.dart';

class SferaReplyParser {
  SferaReplyParser._();

  static T parse<T extends SferaXmlElement>(String input) {
    final xmlDocument = XmlDocument.parse(input);
    final xml = _parseXml(xmlDocument.rootElement);
    return xml as T;
  }

  static SferaXmlElement _parseXml(XmlElement xmlElement) {
    final attributes = <String, String>{};
    final children = <SferaXmlElement>[];

    for (final attribute in xmlElement.attributes) {
      attributes[attribute.name.toString()] = attribute.value;
    }

    for (final childElement in xmlElement.childElements) {
      final child = _parseXml(childElement);
      children.add(child);
    }

    final xmlTextElements = xmlElement.children.whereType<XmlText>();

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
      case SignalPhysicalCharacteristics.elementType:
        return SignalPhysicalCharacteristics(type: type, attributes: attributes, children: children, value: value);
      case SignalFunction.elementType:
        return SignalFunction(type: type, attributes: attributes, children: children, value: value);
      case VirtualBalise.elementType:
        return VirtualBalise(type: type, attributes: attributes, children: children, value: value);
      case VirtualBalisePosition.elementType:
        return VirtualBalisePosition(type: type, attributes: attributes, children: children, value: value);
      case HandshakeAcknowledgement.elementType:
        return HandshakeAcknowledgement(type: type, attributes: attributes, children: children, value: value);
      case HandshakeReject.elementType:
        return HandshakeReject(type: type, attributes: attributes, children: children, value: value);
      case DasOperatingModesSelected.elementType:
        return DasOperatingModesSelected(type: type, attributes: attributes, children: children, value: value);
      case SpContextInformation.elementType:
        return SpContextInformation(type: type, attributes: attributes, children: children, value: value);
      case KilometreReferencePoint.elementType:
        return KilometreReferencePoint(type: type, attributes: attributes, children: children, value: value);
      case KmReference.elementType:
        return KmReference(type: type, attributes: attributes, children: children, value: value);
      case SpAreas.elementType:
        return SpAreas(type: type, attributes: attributes, children: children, value: value);
      case TafTapLocation.elementType:
        return TafTapLocation(type: type, attributes: attributes, children: children, value: value);
      case LocationIdent.elementType:
        return LocationIdent(type: type, attributes: attributes, children: children, value: value);
      case TafTapLocationIdent.elementType:
        return TafTapLocationIdent(type: type, attributes: attributes, children: children, value: value);
      case MultilingualText.elementType:
        return MultilingualText(type: type, attributes: attributes, children: children, value: value);
      case TafTapLocationName.elementType:
        return TafTapLocationName(type: type, attributes: attributes, children: children, value: value);
      case TafTapLocationReference.elementType:
        return TafTapLocationReference(type: type, attributes: attributes, children: children, value: value);
      case StopType.elementType:
        return StopType(type: type, attributes: attributes, children: children, value: value);
      case TafTapLocationNsp.elementType:
        return TafTapLocationNsp.from(attributes: attributes, children: children, value: value);
      case NetworkSpecificParameter.elementType:
        return NetworkSpecificParameter.from(attributes: attributes, children: children, value: value);
      case CurrentLimitation.elementType:
        return CurrentLimitation(type: type, attributes: attributes, children: children, value: value);
      case CurrentLimitationStart.elementType:
        return CurrentLimitationStart(type: type, attributes: attributes, children: children, value: value);
      case CurrentLimitationChange.elementType:
        return CurrentLimitationChange(type: type, attributes: attributes, children: children, value: value);
      case SpCharacteristics.elementType:
        return SpCharacteristics(type: type, attributes: attributes, children: children, value: value);
      case NetworkSpecificPoint.elementType:
        return NetworkSpecificPoint.from(attributes: attributes, children: children, value: value);
      case NetworkSpecificArea.elementType:
        return NetworkSpecificArea(type: type, attributes: attributes, children: children, value: value);
      case AdditionalSpeedRestriction.elementType:
        return AdditionalSpeedRestriction(type: type, attributes: attributes, children: children, value: value);
      case TemporaryConstraints.elementType:
        return TemporaryConstraints(type: type, attributes: attributes, children: children, value: value);
      case TemporaryConstraintReason.elementType:
        return TemporaryConstraintReason(type: type, attributes: attributes, children: children, value: value);
      case Velocity.elementType:
        return Velocity(type: type, attributes: attributes, children: children, value: value);
      case Speeds.elementType:
        return Speeds(type: type, attributes: attributes, children: children, value: value);
      case LineSpeed.elementType:
        return LineSpeed(type: type, attributes: attributes, children: children, value: value);
      case ConnectionTrack.elementType:
        return ConnectionTrack(type: type, attributes: attributes, children: children, value: value);
      case CurveSpeed.elementType:
        return CurveSpeed(type: type, attributes: attributes, children: children, value: value);
      case StationSpeed.elementType:
        return StationSpeed(type: type, attributes: attributes, children: children, value: value);
      case TrainCharacteristicsRef.elementType:
        return TrainCharacteristicsRef(type: type, attributes: attributes, children: children, value: value);
      case TrainCharacteristics.elementType:
        return TrainCharacteristics(type: type, attributes: attributes, children: children, value: value);
      case TcFeatures.elementType:
        return TcFeatures(type: type, attributes: attributes, children: children, value: value);
      case GraduatedSpeedInfoEntity.elementType:
        return GraduatedSpeedInfoEntity(type: type, attributes: attributes, children: children, value: value);
      case GraduatedSpeedInfo.elementType:
        return GraduatedSpeedInfo(type: type, attributes: attributes, children: children, value: value);
      case Balise.elementType:
        return Balise(type: type, attributes: attributes, children: children, value: value);
      case LevelCrossingArea.elementType:
        return LevelCrossingArea(type: type, attributes: attributes, children: children, value: value);
      default:
        return SferaXmlElement(type: type, attributes: attributes, children: children, value: value);
    }
  }
}

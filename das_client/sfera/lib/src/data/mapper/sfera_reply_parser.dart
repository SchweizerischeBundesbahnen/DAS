import 'package:sfera/src/data/dto/additional_speed_restriction.dart';
import 'package:sfera/src/data/dto/b2g_event_payload.dart';
import 'package:sfera/src/data/dto/balise.dart';
import 'package:sfera/src/data/dto/balise_group.dart';
import 'package:sfera/src/data/dto/communication_network.dart';
import 'package:sfera/src/data/dto/connection_track.dart';
import 'package:sfera/src/data/dto/connection_track_description.dart';
import 'package:sfera/src/data/dto/contact.dart';
import 'package:sfera/src/data/dto/contact_list.dart';
import 'package:sfera/src/data/dto/current_limitation.dart';
import 'package:sfera/src/data/dto/current_limitation_change.dart';
import 'package:sfera/src/data/dto/current_limitation_start.dart';
import 'package:sfera/src/data/dto/curve_speed.dart';
import 'package:sfera/src/data/dto/das_operating_modes_selected.dart';
import 'package:sfera/src/data/dto/decisive_gradient_area.dart';
import 'package:sfera/src/data/dto/delay.dart';
import 'package:sfera/src/data/dto/foot_note.dart';
import 'package:sfera/src/data/dto/g2b_event_payload.dart';
import 'package:sfera/src/data/dto/g2b_reply_payload.dart';
import 'package:sfera/src/data/dto/graduated_speed_info.dart';
import 'package:sfera/src/data/dto/graduated_speed_info_entity.dart';
import 'package:sfera/src/data/dto/handshake_acknowledgement.dart';
import 'package:sfera/src/data/dto/handshake_reject.dart';
import 'package:sfera/src/data/dto/journey_profile.dart';
import 'package:sfera/src/data/dto/kilometre_reference_point.dart';
import 'package:sfera/src/data/dto/km_reference.dart';
import 'package:sfera/src/data/dto/level_crossing_area.dart';
import 'package:sfera/src/data/dto/line_foot_notes.dart';
import 'package:sfera/src/data/dto/line_speed.dart';
import 'package:sfera/src/data/dto/location_ident.dart';
import 'package:sfera/src/data/dto/message_header.dart';
import 'package:sfera/src/data/dto/multilingual_text.dart';
import 'package:sfera/src/data/dto/network_specific_area.dart';
import 'package:sfera/src/data/dto/network_specific_event.dart';
import 'package:sfera/src/data/dto/network_specific_parameter.dart';
import 'package:sfera/src/data/dto/network_specific_point.dart';
import 'package:sfera/src/data/dto/op_foot_notes.dart';
import 'package:sfera/src/data/dto/other_contact_type.dart';
import 'package:sfera/src/data/dto/otn_id.dart';
import 'package:sfera/src/data/dto/own_train.dart';
import 'package:sfera/src/data/dto/position_speed.dart';
import 'package:sfera/src/data/dto/related_train_information.dart';
import 'package:sfera/src/data/dto/segment_profile.dart';
import 'package:sfera/src/data/dto/segment_profile_list.dart';
import 'package:sfera/src/data/dto/session_termination.dart';
import 'package:sfera/src/data/dto/sfera_b2g_event_message.dart';
import 'package:sfera/src/data/dto/sfera_g2b_event_message.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message.dart';
import 'package:sfera/src/data/dto/sfera_xml_element.dart';
import 'package:sfera/src/data/dto/signal.dart';
import 'package:sfera/src/data/dto/signal_function.dart';
import 'package:sfera/src/data/dto/signal_id.dart';
import 'package:sfera/src/data/dto/signal_physical_characteristics.dart';
import 'package:sfera/src/data/dto/sp_areas.dart';
import 'package:sfera/src/data/dto/sp_characteristics.dart';
import 'package:sfera/src/data/dto/sp_context_information.dart';
import 'package:sfera/src/data/dto/sp_points.dart';
import 'package:sfera/src/data/dto/sp_zone.dart';
import 'package:sfera/src/data/dto/speeds.dart';
import 'package:sfera/src/data/dto/station_speed.dart';
import 'package:sfera/src/data/dto/stop_type.dart';
import 'package:sfera/src/data/dto/stopping_point_departure_details.dart';
import 'package:sfera/src/data/dto/stopping_point_information.dart';
import 'package:sfera/src/data/dto/taf_tap_location.dart';
import 'package:sfera/src/data/dto/taf_tap_location_ident.dart';
import 'package:sfera/src/data/dto/taf_tap_location_nsp.dart';
import 'package:sfera/src/data/dto/taf_tap_location_reference.dart';
import 'package:sfera/src/data/dto/tc_features.dart';
import 'package:sfera/src/data/dto/teltsi_primary_location_name.dart';
import 'package:sfera/src/data/dto/temporary_constraint_reason.dart';
import 'package:sfera/src/data/dto/temporary_constraints.dart';
import 'package:sfera/src/data/dto/text.dart';
import 'package:sfera/src/data/dto/timing_point.dart';
import 'package:sfera/src/data/dto/timing_point_constraints.dart';
import 'package:sfera/src/data/dto/timing_point_reference.dart';
import 'package:sfera/src/data/dto/tp_id_reference.dart';
import 'package:sfera/src/data/dto/tp_name.dart';
import 'package:sfera/src/data/dto/track_foot_notes.dart';
import 'package:sfera/src/data/dto/train_characteristics.dart';
import 'package:sfera/src/data/dto/train_characteristics_ref.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';
import 'package:sfera/src/data/dto/train_location_information.dart';
import 'package:sfera/src/data/dto/velocity.dart';
import 'package:sfera/src/data/dto/virtual_balise.dart';
import 'package:sfera/src/data/dto/virtual_balise_position.dart';
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

    return _createResolvedType(
        xmlElement.name.toString(), Map.unmodifiable(attributes), List.unmodifiable(children), xmlElement);
  }

  static SferaXmlElement _createResolvedType(
      String type, Map<String, String> attributes, List<SferaXmlElement> children, XmlElement xmlElement) {
    final xmlTextElements = xmlElement.children.whereType<XmlText>();
    final value = xmlTextElements.length == 1 ? xmlTextElements.first.toString() : null;

    switch (type) {
      case SferaG2bReplyMessage.elementType:
        return SferaG2bReplyMessage(type: type, attributes: attributes, children: children, value: value);
      case G2bReplyPayload.elementType:
        return G2bReplyPayload(type: type, attributes: attributes, children: children, value: value);
      case MessageHeader.elementType:
        return MessageHeader(type: type, attributes: attributes, children: children, value: value);
      case JourneyProfile.elementType:
        return JourneyProfile(type: type, attributes: attributes, children: children, value: value);
      case SegmentProfileReference.elementType:
        return SegmentProfileReference(type: type, attributes: attributes, children: children, value: value);
      case OtnId.elementType:
        return OtnId(type: type, attributes: attributes, children: children, value: value);
      case TrainIdentificationDto.elementType:
        return TrainIdentificationDto(type: type, attributes: attributes, children: children, value: value);
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
      case StoppingPointDepartureDetails.elementType:
        return StoppingPointDepartureDetails(type: type, attributes: attributes, children: children, value: value);
      case SegmentProfile.elementType:
        return SegmentProfile(type: type, attributes: attributes, children: children, value: value);
      case SpPoints.elementType:
        return SpPoints(type: type, attributes: attributes, children: children, value: value);
      case BaliseGroup.elementType:
        return BaliseGroup(type: type, attributes: attributes, children: children, value: value);
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
      case TeltsiPrimaryLocationName.elementType:
        return TeltsiPrimaryLocationName(type: type, attributes: attributes, children: children, value: value);
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
      case ConnectionTrackDescription.elementType:
        return ConnectionTrackDescription(type: type, attributes: attributes, children: children, value: value);
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
      case SferaG2bEventMessage.elementType:
        return SferaG2bEventMessage(type: type, attributes: attributes, children: children, value: value);
      case G2bEventPayload.elementType:
        return G2bEventPayload(type: type, attributes: attributes, children: children, value: value);
      case RelatedTrainInformation.elementType:
        return RelatedTrainInformation(type: type, attributes: attributes, children: children, value: value);
      case OwnTrain.elementType:
        return OwnTrain(type: type, attributes: attributes, children: children, value: value);
      case TrainLocationInformation.elementType:
        return TrainLocationInformation(type: type, attributes: attributes, children: children, value: value);
      case Delay.elementType:
        return Delay(type: type, attributes: attributes, children: children, value: value);
      case GraduatedSpeedInfoEntity.elementType:
        return GraduatedSpeedInfoEntity(type: type, attributes: attributes, children: children, value: value);
      case GraduatedSpeedInfo.elementType:
        return GraduatedSpeedInfo(type: type, attributes: attributes, children: children, value: value);
      case Balise.elementType:
        return Balise(type: type, attributes: attributes, children: children, value: value);
      case LevelCrossingArea.elementType:
        return LevelCrossingArea(type: type, attributes: attributes, children: children, value: value);
      case PositionSpeed.elementType:
        return PositionSpeed(type: type, attributes: attributes, children: children, value: value);
      case CommunicationNetwork.elementType:
        return CommunicationNetwork(type: type, attributes: attributes, children: children, value: value);
      case SferaB2gEventMessage.elementType:
        return SferaB2gEventMessage(type: type, attributes: attributes, children: children, value: value);
      case SessionTermination.elementType:
        return SessionTermination(type: type, attributes: attributes, children: children, value: value);
      case B2gEventPayload.elementType:
        return B2gEventPayload(type: type, attributes: attributes, children: children, value: value);
      case NetworkSpecificEvent.elementType:
        return NetworkSpecificEvent.from(attributes: attributes, children: children, value: value);
      case LineFootNotes.elementType:
        return LineFootNotes(attributes: attributes, children: children, value: value);
      case OpFootNotes.elementType:
        return OpFootNotes(attributes: attributes, children: children, value: value);
      case SferaFootNote.elementType:
        return SferaFootNote(attributes: attributes, children: children, value: value);
      case Text.elementType:
        return Text(attributes: attributes, children: children, value: value, xmlValue: xmlElement.innerXml);
      case ContactList.elementType:
        return ContactList(type: type, attributes: attributes, children: children, value: value);
      case Contact.elementType:
        return Contact(type: type, attributes: attributes, children: children, value: value);
      case OtherContactType.elementType:
        return OtherContactType(type: type, attributes: attributes, children: children, value: value);
      case TrackFootNotes.elementType:
        return TrackFootNotes(type: type, attributes: attributes, children: children, value: value);
      case DecisiveGradientArea.elementType:
        return DecisiveGradientArea(type: type, attributes: attributes, children: children, value: value);
      default:
        return SferaXmlElement(type: type, attributes: attributes, children: children, value: value);
    }
  }
}

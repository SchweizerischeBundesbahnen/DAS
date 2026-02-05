import 'package:sfera/src/data/dto/additional_info_dto.dart';
import 'package:sfera/src/data/dto/additional_speed_restriction_dto.dart';
import 'package:sfera/src/data/dto/advised_speed_dto.dart';
import 'package:sfera/src/data/dto/b2g_event_payload_dto.dart';
import 'package:sfera/src/data/dto/balise_dto.dart';
import 'package:sfera/src/data/dto/balise_group_dto.dart';
import 'package:sfera/src/data/dto/change_dto.dart';
import 'package:sfera/src/data/dto/communication_network_dto.dart';
import 'package:sfera/src/data/dto/connection_track_description_dto.dart';
import 'package:sfera/src/data/dto/connection_track_dto.dart';
import 'package:sfera/src/data/dto/contact_dto.dart';
import 'package:sfera/src/data/dto/contact_list_dto.dart';
import 'package:sfera/src/data/dto/current_limitation_change_dto.dart';
import 'package:sfera/src/data/dto/current_limitation_dto.dart';
import 'package:sfera/src/data/dto/current_limitation_start_dto.dart';
import 'package:sfera/src/data/dto/curve_speed_dto.dart';
import 'package:sfera/src/data/dto/das_operating_modes_selected_dto.dart';
import 'package:sfera/src/data/dto/decisive_gradient_area_dto.dart';
import 'package:sfera/src/data/dto/delay_dto.dart';
import 'package:sfera/src/data/dto/foot_note_dto.dart';
import 'package:sfera/src/data/dto/g2b_error.dart';
import 'package:sfera/src/data/dto/g2b_event_payload_dto.dart';
import 'package:sfera/src/data/dto/g2b_message_response.dart';
import 'package:sfera/src/data/dto/g2b_reply_payload_dto.dart';
import 'package:sfera/src/data/dto/general_jp_information_dto.dart';
import 'package:sfera/src/data/dto/general_jp_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/graduated_speed_info_dto.dart';
import 'package:sfera/src/data/dto/graduated_speed_info_entity_dto.dart';
import 'package:sfera/src/data/dto/handshake_acknowledgement_dto.dart';
import 'package:sfera/src/data/dto/handshake_reject_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/jp_context_information_dto.dart';
import 'package:sfera/src/data/dto/jp_context_information_nsp_constraints_dto.dart';
import 'package:sfera/src/data/dto/jp_context_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/kilometre_reference_point_dto.dart';
import 'package:sfera/src/data/dto/km_reference_dto.dart';
import 'package:sfera/src/data/dto/level_crossing_area_dto.dart';
import 'package:sfera/src/data/dto/line_foot_notes_dto.dart';
import 'package:sfera/src/data/dto/line_speed_dto.dart';
import 'package:sfera/src/data/dto/location_ident_dto.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/multilingual_text_dto.dart';
import 'package:sfera/src/data/dto/network_specific_area_dto.dart';
import 'package:sfera/src/data/dto/network_specific_constraint_dto.dart';
import 'package:sfera/src/data/dto/network_specific_event_dto.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/data/dto/network_specific_point_dto.dart';
import 'package:sfera/src/data/dto/op_foot_notes_dto.dart';
import 'package:sfera/src/data/dto/other_contact_type_dto.dart';
import 'package:sfera/src/data/dto/otn_id_dto.dart';
import 'package:sfera/src/data/dto/own_train_dto.dart';
import 'package:sfera/src/data/dto/position_speed_dto.dart';
import 'package:sfera/src/data/dto/reason_text_dto.dart';
import 'package:sfera/src/data/dto/related_train_information_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_list_dto.dart';
import 'package:sfera/src/data/dto/session_termination_dto.dart';
import 'package:sfera/src/data/dto/sfera_b2g_event_message_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_event_message_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/signal_dto.dart';
import 'package:sfera/src/data/dto/signal_function_dto.dart';
import 'package:sfera/src/data/dto/signal_id_dto.dart';
import 'package:sfera/src/data/dto/signal_nsp_dto.dart';
import 'package:sfera/src/data/dto/signal_physical_characteristics_dto.dart';
import 'package:sfera/src/data/dto/sp_areas_dto.dart';
import 'package:sfera/src/data/dto/sp_characteristics_dto.dart';
import 'package:sfera/src/data/dto/sp_context_information_dto.dart';
import 'package:sfera/src/data/dto/sp_points_dto.dart';
import 'package:sfera/src/data/dto/sp_zone_dto.dart';
import 'package:sfera/src/data/dto/speeds_dto.dart';
import 'package:sfera/src/data/dto/station_properties_dto.dart';
import 'package:sfera/src/data/dto/station_property_dto.dart';
import 'package:sfera/src/data/dto/station_speed_dto.dart';
import 'package:sfera/src/data/dto/stop_2_pass_or_pass_2_stop_dto.dart';
import 'package:sfera/src/data/dto/stop_type_dto.dart';
import 'package:sfera/src/data/dto/stopping_point_departure_details_dto.dart';
import 'package:sfera/src/data/dto/stopping_point_information_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_ident_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_nsp_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_reference_dto.dart';
import 'package:sfera/src/data/dto/tc_features_dto.dart';
import 'package:sfera/src/data/dto/teltsi_primary_location_name_dto.dart';
import 'package:sfera/src/data/dto/temporary_constraint_reason_dto.dart';
import 'package:sfera/src/data/dto/temporary_constraints_complex_dto.dart';
import 'package:sfera/src/data/dto/temporary_constraints_dto.dart';
import 'package:sfera/src/data/dto/text_dto.dart';
import 'package:sfera/src/data/dto/timing_point_constraints_dto.dart';
import 'package:sfera/src/data/dto/timing_point_dto.dart';
import 'package:sfera/src/data/dto/timing_point_reference_dto.dart';
import 'package:sfera/src/data/dto/tp_id_reference_dto.dart';
import 'package:sfera/src/data/dto/tp_name_dto.dart';
import 'package:sfera/src/data/dto/track_foot_notes_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_ref_dto.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';
import 'package:sfera/src/data/dto/train_location_information_dto.dart';
import 'package:sfera/src/data/dto/train_run_rerouting_dto.dart';
import 'package:sfera/src/data/dto/velocity_dto.dart';
import 'package:sfera/src/data/dto/virtual_balise_dto.dart';
import 'package:sfera/src/data/dto/virtual_balise_position_dto.dart';
import 'package:xml/xml.dart';

class SferaReplyParser {
  SferaReplyParser._();

  static T parse<T extends SferaXmlElementDto>(String input) {
    final xmlDocument = XmlDocument.parse(input);
    final xml = _parseXml(xmlDocument.rootElement);
    return xml as T;
  }

  static SferaXmlElementDto _parseXml(XmlElement xmlElement) {
    final attributes = <String, String>{};
    final children = <SferaXmlElementDto>[];

    for (final attribute in xmlElement.attributes) {
      attributes[attribute.name.toString()] = attribute.value;
    }

    for (final childElement in xmlElement.childElements) {
      final child = _parseXml(childElement);
      children.add(child);
    }

    return _createResolvedType(
      xmlElement.name.toString(),
      Map.unmodifiable(attributes),
      List.unmodifiable(children),
      xmlElement,
    );
  }

  static SferaXmlElementDto _createResolvedType(
    String type,
    Map<String, String> attributes,
    List<SferaXmlElementDto> children,
    XmlElement xmlElement,
  ) {
    final xmlTextElements = xmlElement.children.whereType<XmlText>();
    final value = xmlTextElements.length == 1 ? xmlTextElements.first.toString() : null;

    switch (type) {
      case SferaG2bReplyMessageDto.elementType:
        return SferaG2bReplyMessageDto(type: type, attributes: attributes, children: children, value: value);
      case G2bReplyPayloadDto.elementType:
        return G2bReplyPayloadDto(type: type, attributes: attributes, children: children, value: value);
      case MessageHeaderDto.elementType:
        return MessageHeaderDto(type: type, attributes: attributes, children: children, value: value);
      case JourneyProfileDto.elementType:
        return JourneyProfileDto(type: type, attributes: attributes, children: children, value: value);
      case SegmentProfileReferenceDto.elementType:
        return SegmentProfileReferenceDto(type: type, attributes: attributes, children: children, value: value);
      case OtnIdDto.elementType:
        return OtnIdDto(type: type, attributes: attributes, children: children, value: value);
      case TrainIdentificationDto.elementType:
        return TrainIdentificationDto(type: type, attributes: attributes, children: children, value: value);
      case SpZoneDto.elementType:
        return SpZoneDto(type: type, attributes: attributes, children: children, value: value);
      case TimingPointConstraintsDto.elementType:
        return TimingPointConstraintsDto(type: type, attributes: attributes, children: children, value: value);
      case TimingPointReferenceDto.elementType:
        return TimingPointReferenceDto(type: type, attributes: attributes, children: children, value: value);
      case TpIdReferenceDto.elementType:
        return TpIdReferenceDto(type: type, attributes: attributes, children: children, value: value);
      case StoppingPointInformationDto.elementType:
        return StoppingPointInformationDto(type: type, attributes: attributes, children: children, value: value);
      case StoppingPointDepartureDetailsDto.elementType:
        return StoppingPointDepartureDetailsDto(type: type, attributes: attributes, children: children, value: value);
      case SegmentProfileDto.elementType:
        return SegmentProfileDto(type: type, attributes: attributes, children: children, value: value);
      case SpPointsDto.elementType:
        return SpPointsDto(type: type, attributes: attributes, children: children, value: value);
      case BaliseGroupDto.elementType:
        return BaliseGroupDto(type: type, attributes: attributes, children: children, value: value);
      case ChangeDto.elementType:
        return ChangeDto.from(attributes: attributes, children: children, value: value);
      case TimingPointDto.elementType:
        return TimingPointDto(type: type, attributes: attributes, children: children, value: value);
      case TpNameDto.elementType:
        return TpNameDto(type: type, attributes: attributes, children: children, value: value);
      case SignalDto.elementType:
        return SignalDto(type: type, attributes: attributes, children: children, value: value);
      case SignalIdDto.elementType:
        return SignalIdDto(type: type, attributes: attributes, children: children, value: value);
      case SignalPhysicalCharacteristicsDto.elementType:
        return SignalPhysicalCharacteristicsDto(type: type, attributes: attributes, children: children, value: value);
      case SignalFunctionDto.elementType:
        return SignalFunctionDto(type: type, attributes: attributes, children: children, value: value);
      case VirtualBaliseDto.elementType:
        return VirtualBaliseDto(type: type, attributes: attributes, children: children, value: value);
      case VirtualBalisePositionDto.elementType:
        return VirtualBalisePositionDto(type: type, attributes: attributes, children: children, value: value);
      case HandshakeAcknowledgementDto.elementType:
        return HandshakeAcknowledgementDto(type: type, attributes: attributes, children: children, value: value);
      case HandshakeRejectDto.elementType:
        return HandshakeRejectDto(type: type, attributes: attributes, children: children, value: value);
      case DasOperatingModesSelectedDto.elementType:
        return DasOperatingModesSelectedDto(type: type, attributes: attributes, children: children, value: value);
      case SpContextInformationDto.elementType:
        return SpContextInformationDto(type: type, attributes: attributes, children: children, value: value);
      case KilometreReferencePointDto.elementType:
        return KilometreReferencePointDto(type: type, attributes: attributes, children: children, value: value);
      case KmReferenceDto.elementType:
        return KmReferenceDto(type: type, attributes: attributes, children: children, value: value);
      case SpAreasDto.elementType:
        return SpAreasDto(type: type, attributes: attributes, children: children, value: value);
      case TafTapLocationDto.elementType:
        return TafTapLocationDto(type: type, attributes: attributes, children: children, value: value);
      case LocationIdentDto.elementType:
        return LocationIdentDto(type: type, attributes: attributes, children: children, value: value);
      case TafTapLocationIdentDto.elementType:
        return TafTapLocationIdentDto(type: type, attributes: attributes, children: children, value: value);
      case MultilingualTextDto.elementType:
        return MultilingualTextDto(type: type, attributes: attributes, children: children, value: value);
      case TeltsiPrimaryLocationNameDto.elementType:
        return TeltsiPrimaryLocationNameDto(type: type, attributes: attributes, children: children, value: value);
      case TafTapLocationReferenceDto.elementType:
        return TafTapLocationReferenceDto(type: type, attributes: attributes, children: children, value: value);
      case StopTypeDto.elementType:
        return StopTypeDto(type: type, attributes: attributes, children: children, value: value);
      case TafTapLocationNspDto.elementType:
        return TafTapLocationNspDto.from(attributes: attributes, children: children, value: value);
      case NetworkSpecificParameterDto.elementType:
        return NetworkSpecificParameterDto.from(
          parent: xmlElement.parentElement,
          attributes: attributes,
          children: children,
          value: value,
        );
      case CurrentLimitationDto.elementType:
        return CurrentLimitationDto(type: type, attributes: attributes, children: children, value: value);
      case CurrentLimitationStartDto.elementType:
        return CurrentLimitationStartDto(type: type, attributes: attributes, children: children, value: value);
      case CurrentLimitationChangeDto.elementType:
        return CurrentLimitationChangeDto(type: type, attributes: attributes, children: children, value: value);
      case SpCharacteristicsDto.elementType:
        return SpCharacteristicsDto(type: type, attributes: attributes, children: children, value: value);
      case NetworkSpecificPointDto.elementType:
        return NetworkSpecificPointDto.from(attributes: attributes, children: children, value: value);
      case NetworkSpecificAreaDto.elementType:
        return NetworkSpecificAreaDto(type: type, attributes: attributes, children: children, value: value);
      case AdditionalSpeedRestrictionDto.elementType:
        return AdditionalSpeedRestrictionDto(type: type, attributes: attributes, children: children, value: value);
      case TemporaryConstraintsDto.elementType:
        return TemporaryConstraintsDto(type: type, attributes: attributes, children: children, value: value);
      case TemporaryConstraintsComplexDto.elementType:
        return TemporaryConstraintsComplexDto(type: type, attributes: attributes, children: children, value: value);
      case TemporaryConstraintReasonDto.elementType:
        return TemporaryConstraintReasonDto(type: type, attributes: attributes, children: children, value: value);
      case VelocityDto.elementType:
        return VelocityDto(type: type, attributes: attributes, children: children, value: value);
      case SpeedsDto.elementType:
        return SpeedsDto(type: type, attributes: attributes, children: children, value: value);
      case LineSpeedDto.elementType:
        return LineSpeedDto(type: type, attributes: attributes, children: children, value: value);
      case ConnectionTrackDto.elementType:
        return ConnectionTrackDto(type: type, attributes: attributes, children: children, value: value);
      case ConnectionTrackDescriptionDto.elementType:
        return ConnectionTrackDescriptionDto(type: type, attributes: attributes, children: children, value: value);
      case CurveSpeedDto.elementType:
        return CurveSpeedDto(type: type, attributes: attributes, children: children, value: value);
      case StationSpeedDto.elementType:
        return StationSpeedDto(type: type, attributes: attributes, children: children, value: value);
      case TrainCharacteristicsRefDto.elementType:
        return TrainCharacteristicsRefDto(type: type, attributes: attributes, children: children, value: value);
      case TrainCharacteristicsDto.elementType:
        return TrainCharacteristicsDto(type: type, attributes: attributes, children: children, value: value);
      case TcFeaturesDto.elementType:
        return TcFeaturesDto(type: type, attributes: attributes, children: children, value: value);
      case SferaG2bEventMessageDto.elementType:
        return SferaG2bEventMessageDto(type: type, attributes: attributes, children: children, value: value);
      case G2bEventPayloadDto.elementType:
        return G2bEventPayloadDto(type: type, attributes: attributes, children: children, value: value);
      case G2bErrorDto.elementType:
        return G2bErrorDto(type: type, attributes: attributes, children: children, value: value);
      case G2bMessageResponseDto.elementType:
        return G2bMessageResponseDto(type: type, attributes: attributes, children: children, value: value);
      case RelatedTrainInformationDto.elementType:
        return RelatedTrainInformationDto(type: type, attributes: attributes, children: children, value: value);
      case OwnTrainDto.elementType:
        return OwnTrainDto(type: type, attributes: attributes, children: children, value: value);
      case TrainLocationInformationDto.elementType:
        return TrainLocationInformationDto(type: type, attributes: attributes, children: children, value: value);
      case DelayDto.elementType:
        return DelayDto(type: type, attributes: attributes, children: children, value: value);
      case GraduatedSpeedInfoEntityDto.elementType:
        return GraduatedSpeedInfoEntityDto(type: type, attributes: attributes, children: children, value: value);
      case GraduatedSpeedInfoDto.elementType:
        return GraduatedSpeedInfoDto(type: type, attributes: attributes, children: children, value: value);
      case BaliseDto.elementType:
        return BaliseDto(type: type, attributes: attributes, children: children, value: value);
      case LevelCrossingAreaDto.elementType:
        return LevelCrossingAreaDto(type: type, attributes: attributes, children: children, value: value);
      case PositionSpeedDto.elementType:
        return PositionSpeedDto(type: type, attributes: attributes, children: children, value: value);
      case CommunicationNetworkDto.elementType:
        return CommunicationNetworkDto(type: type, attributes: attributes, children: children, value: value);
      case SferaB2gEventMessageDto.elementType:
        return SferaB2gEventMessageDto(type: type, attributes: attributes, children: children, value: value);
      case SessionTerminationDto.elementType:
        return SessionTerminationDto(type: type, attributes: attributes, children: children, value: value);
      case B2gEventPayloadDto.elementType:
        return B2gEventPayloadDto(type: type, attributes: attributes, children: children, value: value);
      case NetworkSpecificEventDto.elementType:
        return NetworkSpecificEventDto.from(attributes: attributes, children: children, value: value);
      case LineFootNotesDto.elementType:
        return LineFootNotesDto(attributes: attributes, children: children, value: value);
      case OpFootNotesDto.elementType:
        return OpFootNotesDto(attributes: attributes, children: children, value: value);
      case SferaFootNoteDto.elementType:
        return SferaFootNoteDto(attributes: attributes, children: children, value: value);
      case TextDto.elementType:
        return TextDto(attributes: attributes, children: children, value: value, xmlValue: xmlElement.innerXml);
      case ContactListDto.elementType:
        return ContactListDto(type: type, attributes: attributes, children: children, value: value);
      case ContactDto.elementType:
        return ContactDto(type: type, attributes: attributes, children: children, value: value);
      case OtherContactTypeDto.elementType:
        return OtherContactTypeDto(type: type, attributes: attributes, children: children, value: value);
      case TrackFootNotesDto.elementType:
        return TrackFootNotesDto(type: type, attributes: attributes, children: children, value: value);
      case DecisiveGradientAreaDto.elementType:
        return DecisiveGradientAreaDto(type: type, attributes: attributes, children: children, value: value);
      case NetworkSpecificConstraintDto.elementType:
        return NetworkSpecificConstraintDto.from(attributes: attributes, children: children, value: value);
      case StationPropertiesDto.elementType:
        return StationPropertiesDto(attributes: attributes, children: children, value: value);
      case StationPropertyDto.elementType:
        return StationPropertyDto(attributes: attributes, children: children, value: value);
      case JpContextInformationDto.elementType:
        return JpContextInformationDto(attributes: attributes, children: children, value: value);
      case JpContextInformationNspDto.elementType:
        return JpContextInformationNspDto.from(attributes: attributes, children: children, value: value);
      case JpContextInformationNspConstraintsDto.elementType:
        return JpContextInformationNspConstraintsDto(attributes: attributes, children: children, value: value);
      case AdvisedSpeedDto.elementType:
        return AdvisedSpeedDto(attributes: attributes, children: children, value: value);
      case ReasonTextDto.elementType:
        return ReasonTextDto(attributes: attributes, children: children, value: value);
      case GeneralJpInformationDto.elementType:
        return GeneralJpInformationDto(attributes: attributes, children: children, value: value);
      case GeneralJpInformationNspDto.elementType:
        return GeneralJpInformationNspDto.from(attributes: attributes, children: children, value: value);
      case AdditionalInfoDto.elementType:
        return AdditionalInfoDto(type: type, attributes: attributes, children: children, value: value);
      case SignalNspDto.elementType:
        return SignalNspDto(type: type, attributes: attributes, children: children, value: value);
      case Stop2PassOrPass2StopDto.elementType:
        return Stop2PassOrPass2StopDto(type: type, attributes: attributes, children: children, value: value);
      case TrainRunReroutingDto.elementType:
        return TrainRunReroutingDto(type: type, attributes: attributes, children: children, value: value);
      default:
        return SferaXmlElementDto(type: type, attributes: attributes, children: children, value: value);
    }
  }
}

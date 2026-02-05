import 'package:sfera/src/data/dto/amount_tram_signals_dto.dart';
import 'package:sfera/src/data/dto/departure_dispatch_notification_event_dto.dart';
import 'package:sfera/src/data/dto/departure_dispatch_notification_type_wrapper_dto.dart';
import 'package:sfera/src/data/dto/disturbance_msg_nsp_dto.dart';
import 'package:sfera/src/data/dto/id_nsp_dto.dart';
import 'package:sfera/src/data/dto/km_ref_nsp_dto.dart';
import 'package:sfera/src/data/dto/local_regulation_content_nsp_dto.dart';
import 'package:sfera/src/data/dto/local_regulation_title_nsp_dto.dart';
import 'package:sfera/src/data/dto/new_speed_nsp_dto.dart';
import 'package:sfera/src/data/dto/nsp_dto.dart';
import 'package:sfera/src/data/dto/operating_day_nsp_dto.dart';
import 'package:sfera/src/data/dto/operational_indication_type_nsp_dto.dart';
import 'package:sfera/src/data/dto/operational_indication_uncoded_text_nsp_dto.dart';
import 'package:sfera/src/data/dto/route_table_data_relevant_wrapper_dto.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/speed_nsp_dto.dart';
import 'package:sfera/src/data/dto/track_equipment_type_wrapper_dto.dart';
import 'package:sfera/src/data/dto/train_run_type_nsp_dto.dart';
import 'package:sfera/src/data/dto/xml_curve_speed_dto.dart';
import 'package:sfera/src/data/dto/xml_graduated_speed_info_dto.dart';
import 'package:sfera/src/data/dto/xml_line_foot_notes_dto.dart';
import 'package:sfera/src/data/dto/xml_new_line_speed_dto.dart';
import 'package:sfera/src/data/dto/xml_op_foot_notes_dto.dart';
import 'package:sfera/src/data/dto/xml_station_property_dto.dart';
import 'package:sfera/src/data/dto/xml_station_speed_dto.dart';
import 'package:sfera/src/data/dto/xml_stop_2_pass_or_pass_2_stop_dto.dart';
import 'package:sfera/src/data/dto/xml_track_foot_notes_dto.dart';
import 'package:sfera/src/data/dto/xml_train_run_rerouting_dto.dart';
import 'package:xml/xml.dart';

class NetworkSpecificParameterDto extends SferaXmlElementDto {
  static const String elementType = 'NetworkSpecificParameter';

  NetworkSpecificParameterDto({super.type = elementType, super.attributes, super.children, super.value});

  factory NetworkSpecificParameterDto.from({
    required XmlElement? parent,
    Map<String, String>? attributes,
    List<SferaXmlElementDto>? children,
    String? value,
  }) {
    final attributeName = attributes?['name'];
    if (attributeName == XmlNewLineSpeedDto.elementName) {
      return XmlNewLineSpeedDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == TrackEquipmentTypeWrapperDto.elementName) {
      return TrackEquipmentTypeWrapperDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == XmlCurveSpeedDto.elementName) {
      return XmlCurveSpeedDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == XmlStationSpeedDto.elementName) {
      return XmlStationSpeedDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == XmlGraduatedSpeedInfoDto.elementName) {
      return XmlGraduatedSpeedInfoDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == AmountTramSignalsDto.elementName) {
      return AmountTramSignalsDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == XmlLineFootNotesDto.elementName) {
      return XmlLineFootNotesDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == XmlOpFootNotesDto.elementName) {
      return XmlOpFootNotesDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == XmlTrackFootNotesDto.elementName) {
      return XmlTrackFootNotesDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == IdNetworkSpecificParameterDto.elementName) {
      return IdNetworkSpecificParameterDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == SpeedNetworkSpecificParameterDto.elementName) {
      return SpeedNetworkSpecificParameterDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == NewSpeedNetworkSpecificParameterDto.elementName) {
      return NewSpeedNetworkSpecificParameterDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == XmlStationPropertyDto.elementName) {
      return XmlStationPropertyDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == OperationalIndicationTypeNspDto.elementName) {
      return OperationalIndicationTypeNspDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == OperationalIndicationUncodedTextNspDto.elementName) {
      return OperationalIndicationUncodedTextNspDto(attributes: attributes, children: children, value: value);
    } else if (attributeName != null && LocalRegulationTitleNspDto.matchesElementName(attributeName)) {
      return LocalRegulationTitleNspDto(attributes: attributes, children: children, value: value);
    } else if (attributeName != null && LocalRegulationContentNspDto.matchesElementName(attributeName)) {
      return LocalRegulationContentNspDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == KmRefNspDto.elementName) {
      return KmRefNspDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == RouteTableDataRelevantWrapperDto.elementName) {
      return RouteTableDataRelevantWrapperDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == TrainRunTypeNspDto.elementName) {
      return TrainRunTypeNspDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == OperatingDayNspDto.elementName) {
      return OperatingDayNspDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == DisturbanceMsgNspDto.elementName) {
      return DisturbanceMsgNspDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == XmlStop2PassOrPass2StopDto.elementName) {
      return XmlStop2PassOrPass2StopDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == XmlTrainRunReroutingDto.elementName) {
      return XmlTrainRunReroutingDto(attributes: attributes, children: children, value: value);
    } else if (attributeName == DepartureDispatchNotificationTypeWrapperDto.elementName &&
        _isDepartureDispatchNotificationEvent(parent)) {
      return DepartureDispatchNotificationTypeWrapperDto(attributes: attributes, children: children, value: value);
    }
    return NetworkSpecificParameterDto(attributes: attributes, children: children, value: value);
  }

  String get name => attributes['name']!;

  String get nspValue => attributes['value']!;

  @override
  bool validate() {
    return validateHasAttribute('name') && validateHasAttribute('value') && super.validate();
  }

  @override
  String toString() {
    return 'NetworkSpecificParameterDto{name: $name, nspValue: $nspValue}';
  }

  static bool _isDepartureDispatchNotificationEvent(XmlElement? parent) {
    if (parent == null) return false;
    final name = DepartureDispatchNotificationEventDto.groupNameValue;
    return parent.toXmlString().contains('$name</${NspDto.groupNameElement}>');
  }
}

extension NetworkSpecificParametersExtension on Iterable<NetworkSpecificParameterDto> {
  NetworkSpecificParameterDto? withName(String name) => where((it) => it.name == name).firstOrNull;
}

import 'package:app/sfera/src/model/amount_tram_signals.dart';
import 'package:app/sfera/src/model/sfera_xml_element.dart';
import 'package:app/sfera/src/model/track_equipment_type_wrapper.dart';
import 'package:app/sfera/src/model/xml_curve_speed.dart';
import 'package:app/sfera/src/model/xml_graduated_speed_info.dart';
import 'package:app/sfera/src/model/xml_line_foot_notes.dart';
import 'package:app/sfera/src/model/xml_new_line_speed.dart';
import 'package:app/sfera/src/model/xml_op_foot_notes.dart';
import 'package:app/sfera/src/model/xml_station_speed.dart';
import 'package:app/sfera/src/model/xml_track_foot_notes.dart';

class NetworkSpecificParameter extends SferaXmlElement {
  static const String elementType = 'NetworkSpecificParameter';

  NetworkSpecificParameter({super.type = elementType, super.attributes, super.children, super.value});

  factory NetworkSpecificParameter.from(
      {Map<String, String>? attributes, List<SferaXmlElement>? children, String? value}) {
    if (attributes?['name'] == XmlNewLineSpeed.elementName) {
      return XmlNewLineSpeed(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == TrackEquipmentTypeWrapper.elementName) {
      return TrackEquipmentTypeWrapper(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == XmlCurveSpeed.elementName) {
      return XmlCurveSpeed(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == XmlStationSpeed.elementName) {
      return XmlStationSpeed(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == XmlGraduatedSpeedInfo.elementName) {
      return XmlGraduatedSpeedInfo(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == AmountTramSignals.elementName) {
      return AmountTramSignals(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == XmlLineFootNotes.elementName) {
      return XmlLineFootNotes(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == XmlOpFootNotes.elementName) {
      return XmlOpFootNotes(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == XmlTrackFootNotes.elementName) {
      return XmlTrackFootNotes(attributes: attributes, children: children, value: value);
    }
    return NetworkSpecificParameter(attributes: attributes, children: children, value: value);
  }

  String get name => attributes['name']!;

  String get nspValue => attributes['value']!;

  @override
  bool validate() {
    return validateHasAttribute('name') && validateHasAttribute('value') && super.validate();
  }

  @override
  String toString() {
    return 'NetworkSpecificParameter{name: $name, nspValue: $nspValue}';
  }
}

// extensions

extension NetworkSpecificParametersExtension on Iterable<NetworkSpecificParameter> {
  NetworkSpecificParameter? withName(String name) => where((it) => it.name == name).firstOrNull;
}

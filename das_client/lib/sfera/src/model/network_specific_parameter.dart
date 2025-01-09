import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/track_equipment_type_wrapper.dart';
import 'package:das_client/sfera/src/model/xml_curve_speed.dart';
import 'package:das_client/sfera/src/model/xml_graduated_speed_info.dart';
import 'package:das_client/sfera/src/model/xml_new_line_speed.dart';
import 'package:das_client/sfera/src/model/xml_station_speed.dart';

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
    }
    return NetworkSpecificParameter(attributes: attributes, children: children, value: value);
  }

  String get name => attributes['name']!;

  String get nspValue => attributes['value']!;

  @override
  bool validate() {
    return validateHasAttribute('name') && validateHasAttribute('value') && super.validate();
  }
}

// extensions

extension NetworkSpecificParametersExtension on Iterable<NetworkSpecificParameter> {
  NetworkSpecificParameter? withName(String name) => where((it) => it.name == name).firstOrNull;
}

import 'package:sfera/src/model/curve_point_network_specific_point.dart';
import 'package:sfera/src/model/new_line_speed_network_specific_point.dart';
import 'package:sfera/src/model/nsp.dart';
import 'package:sfera/src/model/sfera_xml_element.dart';
import 'package:sfera/src/model/track_foot_notes_nsp.dart';
import 'package:sfera/src/model/whistle_network_specific_point.dart';

class NetworkSpecificPoint extends Nsp {
  static const String elementType = 'NetworkSpecificPoint';

  NetworkSpecificPoint({super.type = elementType, super.attributes, super.children, super.value});

  double get location => double.parse(attributes['location']!);

  factory NetworkSpecificPoint.from({Map<String, String>? attributes, List<SferaXmlElement>? children, String? value}) {
    final groupName = children?.where((it) => it.type == Nsp.groupNameElement).firstOrNull;
    if (groupName?.value == NewLineSpeedNetworkSpecificPoint.elementName) {
      return NewLineSpeedNetworkSpecificPoint(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == CurvePointNetworkSpecificPoint.elementName) {
      return CurvePointNetworkSpecificPoint(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == WhistleNetworkSpecificPoint.elementName) {
      return WhistleNetworkSpecificPoint(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == TrackFootNotesNsp.elementName) {
      return TrackFootNotesNsp(attributes: attributes, children: children, value: value);
    }
    return NetworkSpecificPoint(attributes: attributes, children: children, value: value);
  }

  @override
  bool validate() {
    return validateHasAttribute('location') && super.validate();
  }
}

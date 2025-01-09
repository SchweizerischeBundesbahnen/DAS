import 'package:das_client/sfera/src/model/curve_point_network_specific_point.dart';
import 'package:das_client/sfera/src/model/network_specific_parameter.dart';
import 'package:das_client/sfera/src/model/new_line_speed_network_specific_point.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/sp_generic_point.dart';
import 'package:das_client/sfera/src/model/whistle_network_specific_point.dart';

class NetworkSpecificPoint extends SpGenericPoint {
  static const String elementType = 'NetworkSpecificPoint';

  NetworkSpecificPoint({super.type = elementType, super.attributes, super.children, super.value});

  factory NetworkSpecificPoint.from({Map<String, String>? attributes, List<SferaXmlElement>? children, String? value}) {
    if (attributes?['name'] == NewLineSpeedNetworkSpecificPoint.elementName) {
      return NewLineSpeedNetworkSpecificPoint(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == CurvePointNetworkSpecificPoint.elementName) {
      return CurvePointNetworkSpecificPoint(attributes: attributes, children: children, value: value);
    } else if (attributes?['name'] == WhistleNetworkSpecificPoint.elementName) {
      return WhistleNetworkSpecificPoint(attributes: attributes, children: children, value: value);
    }
    return NetworkSpecificPoint(attributes: attributes, children: children, value: value);
  }

  String? get name => attributes['name'];

  Iterable<NetworkSpecificParameter> get parameters => children.whereType<NetworkSpecificParameter>();

  @override
  bool validate() {
    return validateHasChildOfType<NetworkSpecificParameter>() && super.validate();
  }
}

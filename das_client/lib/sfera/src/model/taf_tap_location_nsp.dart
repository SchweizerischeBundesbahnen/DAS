import 'package:das_client/sfera/src/model/nsp.dart';
import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/station_speed_nsp.dart';

class TafTapLocationNsp extends Nsp {
  static const String elementType = 'TAF_TAP_Location_NSP';

  TafTapLocationNsp({super.type = elementType, super.attributes, super.children, super.value});

  factory TafTapLocationNsp.from({Map<String, String>? attributes, List<SferaXmlElement>? children, String? value}) {
    if (attributes?['name'] == StationSpeedNsp.elementName) {
      return StationSpeedNsp(attributes: attributes, children: children, value: value);
    }
    return TafTapLocationNsp(attributes: attributes, children: children, value: value);
  }
}

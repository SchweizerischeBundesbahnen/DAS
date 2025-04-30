import 'package:app/sfera/src/model/line_foot_notes_nsp.dart';
import 'package:app/sfera/src/model/new_line_speed_taf_tap_location.dart';
import 'package:app/sfera/src/model/nsp.dart';
import 'package:app/sfera/src/model/op_foot_notes_nsp.dart';
import 'package:app/sfera/src/model/sfera_xml_element.dart';
import 'package:app/sfera/src/model/station_speed_nsp.dart';

class TafTapLocationNsp extends Nsp {
  static const String elementType = 'TAF_TAP_Location_NSP';

  TafTapLocationNsp({super.type = elementType, super.attributes, super.children, super.value});

  factory TafTapLocationNsp.from({Map<String, String>? attributes, List<SferaXmlElement>? children, String? value}) {
    final groupName = children?.where((it) => it.type == Nsp.groupNameElement).firstOrNull;
    if (groupName?.value == StationSpeedNsp.elementName) {
      return StationSpeedNsp(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == NewLineSpeedTafTapLocation.elementName) {
      return NewLineSpeedTafTapLocation(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == LineFootNotesNsp.elementName) {
      return LineFootNotesNsp(attributes: attributes, children: children, value: value);
    } else if (groupName?.value == OpFootNotesNsp.elementName) {
      return OpFootNotesNsp(attributes: attributes, children: children, value: value);
    }
    return TafTapLocationNsp(attributes: attributes, children: children, value: value);
  }
}

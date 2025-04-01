import 'package:das_client/sfera/src/model/enums/taf_tap_location_type.dart';
import 'package:das_client/sfera/src/model/enums/xml_enum.dart';
import 'package:das_client/sfera/src/model/line_foot_notes_nsp.dart';
import 'package:das_client/sfera/src/model/new_line_speed_taf_tap_location.dart';
import 'package:das_client/sfera/src/model/op_foot_notes_nsp.dart';
import 'package:das_client/sfera/src/model/sfera_segment_xml_element.dart';
import 'package:das_client/sfera/src/model/station_speed_nsp.dart';
import 'package:das_client/sfera/src/model/taf_tap_location_ident.dart';
import 'package:das_client/sfera/src/model/taf_tap_location_name.dart';
import 'package:das_client/sfera/src/model/taf_tap_location_nsp.dart';

class TafTapLocation extends SferaSegmentXmlElement {
  static const String elementType = 'TAF_TAP_Location';

  TafTapLocation({super.type = elementType, super.attributes, super.children, super.value});

  TafTapLocationIdent get locationIdent => children.whereType<TafTapLocationIdent>().first;

  Iterable<TafTapLocationName> get locationNames => children.whereType<TafTapLocationName>();

  TafTapLocationType? get locationType =>
      XmlEnum.valueOf<TafTapLocationType>(TafTapLocationType.values, attributes['TAF_TAP_location_type']);

  String get abbreviation => attributes['TAF_TAP_location_abbreviation'] ?? '';

  Iterable<TafTapLocationNsp> get nsp => children.whereType<TafTapLocationNsp>();

  StationSpeedNsp? get stationSpeed => children.whereType<StationSpeedNsp>().firstOrNull;

  NewLineSpeedTafTapLocation? get newLineSpeed => children.whereType<NewLineSpeedTafTapLocation>().firstOrNull;

  OpFootNotesNsp? get opFootNotes => children.whereType<OpFootNotesNsp>().firstOrNull;

  LineFootNotesNsp? get lineFootNotes => children.whereType<LineFootNotesNsp>().firstOrNull;

  @override
  bool validate() {
    return validateHasChildOfType<TafTapLocationIdent>() && super.validate();
  }
}

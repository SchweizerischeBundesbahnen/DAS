import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/taf_tap_location_ident.dart';
import 'package:das_client/sfera/src/model/taf_tap_location_name.dart';

class TafTapLocation extends SferaXmlElement {
  static const String elementType = 'TAF_TAP_Location';

  TafTapLocation({super.type = elementType, super.attributes, super.children, super.value});

  TafTapLocationIdent get locationIdent => children.whereType<TafTapLocationIdent>().first;

  Iterable<TafTapLocationName> get locationNames => children.whereType<TafTapLocationName>();

  @override
  bool validate() {
    return validateHasChildOfType<TafTapLocationIdent>() && super.validate();
  }
}

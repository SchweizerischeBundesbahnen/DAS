import 'package:das_client/sfera/src/model/sfera_xml_element.dart';

class TafTapLocationReference extends SferaXmlElement {
  static const String elementType = 'TAF_TAP_LocationReference';

  TafTapLocationReference({super.type = elementType, super.attributes, super.children, super.value});

  String get countryCodeISO => childrenWithType('CountryCodeISO').first.value!;

  int get locationPrimaryCode => int.parse(childrenWithType('LocationPrimaryCode').first.value!);

  @override
  bool validate() {
    return validateHasChild('CountryCodeISO') && validateHasChildInt('LocationPrimaryCode') && super.validate();
  }
}

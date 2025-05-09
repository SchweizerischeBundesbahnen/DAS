import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class TafTapLocationReferenceDto extends SferaXmlElementDto {
  static const String elementType = 'TAF_TAP_LocationReference';

  static const String _countryCodeISOAttribute = 'teltsi_CountryCodeISO';
  static const String _locationPrimaryCodeAttribute = 'teltsi_LocationPrimaryCode';

  TafTapLocationReferenceDto({super.type = elementType, super.attributes, super.children, super.value});

  String get countryCodeISO => childrenWithType(_countryCodeISOAttribute).first.value!;

  int get locationPrimaryCode => int.parse(childrenWithType(_locationPrimaryCodeAttribute).first.value!);

  @override
  bool validate() {
    return validateHasChild(_countryCodeISOAttribute) &&
        validateHasChildInt(_locationPrimaryCodeAttribute) &&
        super.validate();
  }
}

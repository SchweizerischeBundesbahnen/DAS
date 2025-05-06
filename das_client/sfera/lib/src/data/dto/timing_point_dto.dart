import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/taf_tap_location_reference_dto.dart';
import 'package:sfera/src/data/dto/tp_name_dto.dart';

class TimingPointDto extends SferaXmlElementDto {
  static const String elementType = 'TimingPoint';

  TimingPointDto({super.type = elementType, super.attributes, super.children, super.value});

  String get id => attributes['TP_ID']!;

  double get location => double.parse(attributes['location']!);

  Iterable<TpNameDto> get names => children.whereType<TpNameDto>();

  TafTapLocationReferenceDto? get locationReference => children.whereType<TafTapLocationReferenceDto>().firstOrNull;

  @override
  bool validate() {
    return validateHasAttribute('TP_ID') && validateHasAttributeDouble('location') && super.validate();
  }
}

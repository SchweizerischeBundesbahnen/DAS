import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

class StoppingPointDepartureDetailsDto extends SferaXmlElementDto {
  static const String elementType = 'StoppingPointDepartureDetails';

  StoppingPointDepartureDetailsDto({super.type = elementType, super.attributes, super.children, super.value});

  DateTime get departureTime => DateTime.parse(attributes['departureTime']!);

  @override
  bool validate() {
    return validateHasAttribute('departureTime') && super.validate();
  }
}

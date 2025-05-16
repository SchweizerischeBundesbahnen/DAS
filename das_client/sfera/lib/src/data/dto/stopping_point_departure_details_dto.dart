import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/mapper/datetime_x.dart';

class StoppingPointDepartureDetailsDto extends SferaXmlElementDto {
  static const String elementType = 'StoppingPointDepartureDetails';

  StoppingPointDepartureDetailsDto({super.type = elementType, super.attributes, super.children, super.value});

  DateTime get departureTime => DateTime.parse(attributes['departureTime']!);

  DateTime? get plannedDepartureTime => DateTimeX.parseNullable(attributes['plannedDepartureTime']);

  @override
  bool validate() {
    return validateHasAttribute('departureTime') && super.validate();
  }
}

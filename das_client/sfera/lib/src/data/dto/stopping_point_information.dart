import 'package:sfera/src/data/dto/sfera_xml_element.dart';
import 'package:sfera/src/data/dto/stop_type.dart';
import 'package:sfera/src/data/dto/stopping_point_departure_details.dart';

class StoppingPointInformation extends SferaXmlElement {
  static const String elementType = 'StoppingPointInformation';

  StoppingPointInformation({super.type = elementType, super.attributes, super.children, super.value});

  StopType? get stopType => children.whereType<StopType>().firstOrNull;

  StoppingPointDepartureDetails? get departureDetails =>
      children.whereType<StoppingPointDepartureDetails>().firstOrNull;
}

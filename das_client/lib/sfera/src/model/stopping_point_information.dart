import 'package:das_client/sfera/src/model/sfera_xml_element.dart';
import 'package:das_client/sfera/src/model/stop_type.dart';
import 'package:das_client/sfera/src/model/stopping_point_departure_details.dart';

class StoppingPointInformation extends SferaXmlElement {
  static const String elementType = 'StoppingPointInformation';

  StoppingPointInformation({super.type = elementType, super.attributes, super.children, super.value});

  StopType? get stopType => children.whereType<StopType>().firstOrNull;

  StoppingPointDepartureDetails? get departureDetails =>
      children.whereType<StoppingPointDepartureDetails>().firstOrNull;
}

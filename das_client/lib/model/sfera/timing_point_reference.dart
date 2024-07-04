import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/sfera_xml_element.dart';

class TimingPointReference extends SferaXmlElement {
  static const String elementType = "TimingPointReference";

  TimingPointReference({super.type = elementType, super.attributes, super.children, super.value});
}
